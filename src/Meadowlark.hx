package;

import handlers.*;
import handlers.api.*;
import haxe.Json;
import haxe.Timer;
import js.Node;
import js.node.Cluster;
import js.node.Domain;
import js.node.Fs;
import js.node.http.Server;
import js.node.Process;
import js.node.stdio.Console;
import js.npm.ConnectBundle;
import js.npm.ConnectRest;
import js.npm.Express;
import js.npm.express.Csurf;
import js.npm.ExpressHandlebars;
import js.npm.express.Compression;
import js.npm.express.CookieParser;
import js.npm.express.Cors;
import js.npm.express.ErrorHandler;
import js.npm.ConnectMongo;
import js.npm.express.Morgan;
import js.npm.express.Session;
import js.npm.express.BodyParser;
import js.npm.express.Request;
import js.npm.express.Response;
import js.npm.express.Static;
import js.npm.formidable.IncomingForm;
import js.npm.NodeEnvFile;
import js.npm.Nodemailer;
import js.npm.nodemailer.Transporter;
import lib.Auth;
import lib.Bundles;
import lib.GeoCode;
import lib.Twitter;
import models.Dealer;
import promhx.Deferred;
import promhx.Promise;

using Lambda;

private typedef WeatherLocation = {
	name : String,
	?forecastUrl : String,
	?iconUrl : String,
	?weather : String,
	?temp : String
}

class Meadowlark
{
	var server : Server;
	var app : Express;
	var mailer : Transporter;
	var logger : Logger;

	public static function main() {
		if(Node.process.env.NO_SERVER != null) return;
		#if cluster
		new MeadowlarkCluster().start();
		#else
		new Meadowlark().start();
		#end
	}

	public function new() {
		try {
			new NodeEnvFile(Node.__dirname + '/.env');
		} catch(e : js.Error) {}

		Credentials.create(Node.process.env);
		
		app = new Express();
		logger = Logger.instance;

		Database.connect(app);

		var handlebars = ExpressHandlebars.create({
			defaultLayout: 'main',
			helpers: {
				section: function(name : String, options : Dynamic) {
					var self = untyped __js__('this');
					if(self._sections == null) self._sections = {};
					Reflect.setField(self._sections, name, options.fn(self));
					return null;
				},
				"static": function(name) {
					return lib.Static.map(name);
				}
			}
		});

		app.engine('handlebars', handlebars.engine);
		app.set('view engine', 'handlebars');

		app.set('port', Node.process.env.PORT != null ? Node.process.env.PORT : 3000);
		#if ssl
		app.set('sslPort', Node.process.env.SSLPORT != null ? Node.process.env.SSLPORT : 3001);
		#end

		///// Mailer /////

		mailer = Nodemailer.createTransport({
			service: 'gmail',
			auth: {
				user: Credentials.instance.google.gmail.user,
				pass: Credentials.instance.google.gmail.password
			}
		});

		///// Error catching with domains /////

		app.use(function(req : Request, res : Response, next) {
			var domain = js.node.Domain.create();
			domain.on('error', function(err) {
				logger.error(err);
				try {
					haxe.Timer.delay(function() {
						logger.error("Failsafe shutdown.");
						Node.process.exit(1);
					}, 5000);

					var worker = js.node.Cluster.cluster.worker;

					if(worker != null) worker.disconnect();
					if(server != null) server.close();

					try {
						next(err);
					} catch(err : Dynamic) {
						// if Express error route failed, try plain Node response
						logger.error('Express error mechanism failed.\n');
						logger.error(err);
						res.statusCode = 500;
						res.setHeader('content-type', 'text/plain');
						res.end('Server error.');						
					}
				} catch(err : Dynamic) {
					logger.error('Unable to send 500 response.\n');
					logger.error(err);
				}
			});

			domain.add(req);
			domain.add(res);

			domain.run(next);
		});		

		///// Logging /////

		switch(app.get('env')) {
			case 'development':
				app.use(new Morgan(MorganFormat.dev));
				app.use(new ErrorHandler());

				app.use(function(req,res,next) {
					var cluster = js.node.Cluster.cluster;
					if(cluster.isWorker) logger.log('Worker %d received request', cluster.worker.id);
					next();
				});

				Database.seed();
			case _:
		}

		///// Files and Parsers /////

		app.use(new ConnectBundle(Bundles.connectBundleOptions));
		app.use(new Compression());
		app.use(new Static(Node.__dirname + '/public'));
		app.use(BodyParser.urlencoded({extended: true}));
		app.use(new CookieParser(Credentials.instance.cookieSecret));

		app.use(new Session({
			secret: Credentials.instance.cookieSecret,
			store: ConnectMongo.construct(Session, {mongooseConnection: Database.instance.connection}),
			resave: false,
			saveUninitialized: false
		}));

		///// Authentication /////

		var auth = new Auth(app, {
			providers: Credentials.instance.authProviders,
			successRedirect: '/user/account',
			failureRedirect: '/unauthorized'
		});
		auth.init();
		auth.registerRoutes();

		///// Tests /////

		app.use(function(req : Request, res : Response, next) {
			res.locals.showTests = app.get('env') != 'production' && req.query.test == '1';
			next();
		});

		///// View Partials and Weather /////

		var weatherCache = {
			refreshed: 0.0,
			refreshing: false,
			updateFrequency: 360000, // 1 hour
			locations: [
				{
					name: 'Portland',
					forecastUrl: 'http://www.wunderground.com/US/OR/Portland.html',
					iconUrl: 'http://icons-ak.wxug.com/i/c/k/cloudy.gif',
					weather: 'Overcast',
					temp: '54.1 F (12.3 C)'
				},
				{
					name: 'Bend',
					forecastUrl: 'http://www.wunderground.com/US/OR/Bend.html',
					iconUrl: 'http://icons-ak.wxug.com/i/c/k/partlycloudy.gif',
					weather: 'Partly Cloudy',
					temp: '55.0 F (12.8 C)'
				},
				{
					name: 'Manzanita',
					forecastUrl: 'http://www.wunderground.com/US/OR/Manzanita.html',
					iconUrl: 'http://icons-ak.wxug.com/i/c/k/rain.gif',
					weather: 'Light Rain',
					temp: '55.0 F (12.8 C)'
				}
			]
		};

		#if weather
		refreshWeatherData(weatherCache);
		#end

		app.use(function(req : Request, res : Response, next) {
			#if weather
			refreshWeatherData(weatherCache);
			#end
			if(!res.locals.partials) res.locals.partials = {};
			res.locals.partials.weather = {locations: weatherCache.locations};
			next();
		});

		///// Flash messages /////

		app.use(function(req : Request, res : Response, next) {
			var session = Session.session(req);
			res.locals.flash = session.flash;
			Reflect.deleteField(session, 'flash');
			next();
		});		

		///// Easter egg /////

		app.use(function(req : Request, res : Response, next) {
			var now = Date.now();
			res.locals.logoImage = now.getMonth() == 11 && now.getDate() == 19
				? lib.Static.map('/img/logo_bud_clark.jpg')
				: lib.Static.map('/img/logo.png');
			next();
		});

		///// Twitter /////

		#if twitter
		var topTweets = {
			count: 10,
			lastRefreshed: 0.0,
			refreshInterval: 15 * 60 * 1000,
			tweets: []
		};

		app.use(function(req : Request, res : Response, next) {
			if(Date.now().getTime() < topTweets.lastRefreshed + topTweets.refreshInterval) {
				res.locals.tweets = topTweets.tweets;
				next();
				return;
			}

			var twitter = new Twitter();

			twitter.search('#haxe', topTweets.count, function(result) {
				var formattedTweets = [];
				var promises = [];
				var embedOpts = { omit_script: 1 };
				var statuses : Iterable<Dynamic> = untyped result.statuses;
				for(status in statuses) {
					var def = new promhx.Deferred();
					promises.push(def.promise());
					twitter.embed(status.id_str, embedOpts, function(embed) {
						if(embed != null) formattedTweets.push(embed.html);
						def.resolve(true);
					});
				}

				Promise.whenAll(promises).then(function(_) {
					topTweets.lastRefreshed = Date.now().getTime();
					topTweets.tweets = formattedTweets;

					res.locals.tweets = topTweets.tweets;
					next();
				});
			});
		});
		#end

		///// Geocoding /////

		#if geocoding
		var dealerCache = {
			lastRefreshed: 0.0,
			refreshInterval: 60 * 60 * 1000,
			jsonUrl: '/dealers.json',
			geocodeLimit: 2000,
			geocodeCount: 0.0,
			geocodeBegin: 0.0,
			jsonFile: '',
			refresh: null
		};

		var geocodeDealer = function(dealer : Dealer) : Promise<Dealer> {
			var def = new Deferred();
			var addr = dealer.getAddress(' ');

			if(addr == dealer.geocodedAddress) {
				def.resolve(dealer);       // already geocoded
				return def.promise();
			}
			else if(dealerCache.geocodeCount >= dealerCache.geocodeLimit) {
				// has 24 hours passed since we last started geocoding?
				if(Date.now().getTime() > dealerCache.geocodeCount + 24 * 60 * 60 * 1000) {
					dealerCache.geocodeBegin = Date.now().getTime();
					dealerCache.geocodeCount = 0;
				} else {
					// we can't geocode this now: we've reached our usage limit
					def.resolve(dealer);
					return def.promise();
				}
			}

			GeoCode.find(addr, function(err, coords) {
				dealerCache.geocodeCount++;
				if(err != null) {
					logger.error('Geocoding failure for $addr');
					def.resolve(dealer);
				} else {
					logger.log('Added geocoding coordinates for $addr:' + Std.string(coords));
					dealer.lat = coords.lat;
					dealer.lng = coords.lng;
					dealer.geocodedAddress = addr;
					dealer.save(function(err, d) def.resolve(dealer));
				}
			});

			return def.promise();
		};

		dealerCache.jsonFile = Node.__dirname + '/public' + dealerCache.jsonUrl;

		dealerCache.refresh = function(cb) {
			if(Date.now().getTime() > dealerCache.lastRefreshed + dealerCache.refreshInterval) {
				// we need to refresh the cache
				Dealer.build().find({ active: true }, function(err, dealers : Array<Dealer>) {
					if(err != null) {
						logger.error('Error fetching dealers: '+ err);
						cb();
						return;
					}

					Promise.whenAll(dealers.map(geocodeDealer)).then(function(dealers) {
						// we now write all the dealers out to our cached JSON file
						Fs.writeFileSync(dealerCache.jsonFile, Json.stringify(dealers));
						logger.log('Updated dealers cache file: ' + dealerCache.jsonFile);
						// all done -- invoke callback
						cb();
					});
				});
			}
		};

		var refreshDealerCacheForever = null;
		refreshDealerCacheForever = function() {
			dealerCache.refresh(function() {
				Timer.delay(refreshDealerCacheForever, dealerCache.refreshInterval);
			});
		};

		// Start the caching
		if(!Fs.existsSync(dealerCache.jsonFile)) Fs.writeFileSync(dealerCache.jsonFile, Json.stringify([]));
		refreshDealerCacheForever();
		#end

		///// Rest API routes /////

		var apiOptions = {
			context: '/api',
			domain: {
				closeWorker: function(err, req, res) {
					logger.error(err);
					Timer.delay(function() {
						logger.log('Server shutting down after API domain error.');
						Node.process.exit(1);
					}, 5000);
					if(server != null) server.close();
					var worker = Cluster.cluster.worker;
					if(worker != null) worker.disconnect();
				}
			}
		};

		// If you want to use the api.meadowlark subdomain:
		//app.use(new js.npm.express.VHost('api.*', ConnectRest.rester(apiOptions)));

		app.use('/api', new Cors());
		app.use(ConnectRest.rester(apiOptions));

		var apiAttractions = new Attractions();

		// Cannot use a function reference directly for ConnectRest!
		ConnectRest.get('/attractions', function(r,c,cb) apiAttractions.get(r,c,cb));
		ConnectRest.get('/attraction/:id', function(r,c,cb) apiAttractions.getById(r,c,cb));
		ConnectRest.post('/attraction', function(r,c,cb) apiAttractions.post(r,c,cb));

		/// After Rest API, use csurf ///

		var form : IncomingForm<Request> = new IncomingForm();

		app.use(function(req : Request, res : Response, next) {
			var contentType : String = Reflect.field(untyped req.headers, 'content-type');
			if(contentType != null && contentType.indexOf('multipart/form-data') >= 0) {
				IncomingFormHelper.parse(req, function(err, fields, files) {
					if(fields._csrf) untyped req.body._csrf = fields._csrf;
					next();
				});
			}
			else next();
		});
		app.use(new Csurf());
		app.use(function(req : Request, res : Response, next) {
			res.locals._csrfToken = Csurf.csrfToken(req);
			next();
		});

		///// Site routes /////

		var main = new Main();

		app.get('/', main.home);
		app.get('/about', main.about);

		var vacations = new Vacations();

		app.get('/set-currency/:currency', vacations.setCurrency);
		app.get('/vacations', vacations.vacations);

		var cart = new Cart(mailer);

		app.get('/cart/add', cart.add);
		app.post('/cart/checkout', cart.checkout);			

		var newsletter = new Newsletter();

		app.get('/newsletter', newsletter.newsletter);
		app.post('/process', newsletter.process);

		var contest = new VacationPhotoContest();

		app.get('/contest/vacation-photo', contest.vacationPhoto);
		app.post('/contest/vacation-photo/:year/:month', contest.vacationPhotoSumbission);

		// Tour routes are handled by the static router.

		var notifications = new Notifications();

		app.get('/notify-me-when-in-season', notifications.notifyMe);
		app.post('/notify-me-when-in-season', notifications.notifyMeSubmission);

		var test = new Test();

		app.get('/data/nursery-rhyme', test.nurseryRhyme);
		app.get('/epic-fail', test.epicFail);

		var user = new handlers.User();

		app.get('/user/account', [user.customerOnly, user.account]);
		app.get('/user/account/order-history', [user.customerOnly, user.orderHistory]);
		app.get('/user/account/email-prefs', [user.customerOnly, user.emailPrefs]);

		app.get('/sales', [user.employeeOnly, user.sales]);

		///// Static routing /////

		var autoViews = {};

		app.use(function(req : Request, res : Response, next) {
			var path = req.path.toLowerCase();
			// check cache; if it's there, render the view
			if(Reflect.hasField(autoViews, path)) 
				return res.render(Reflect.field(autoViews, path));

			// if it's not in the cache, see if there's
			// a .handlebars file that matches
			if(Fs.existsSync(Node.__dirname + '/views' + path + '.handlebars')) {
				var cachePath = ~/^\//.replace(path, '');
				Reflect.setField(autoViews, path, cachePath);
				return res.render(cachePath);
			}

			// no view found; pass on to 404 handler
			next();
		});

		///// Error handling /////

		app.use(function(req : Request, res : Response) {
			res.status(404);
			res.render('404');
		});

		app.use(function(err, req : js.npm.express.Request, res : js.npm.express.Response, next) {
			if (err.code == Csurf.errorCode) {
				res.status(403);
				res.send('Session has expired or form tampered with.');
			} else {				
				logger.error(err);
				res.status(500);
				res.render('500');
			}
		});
	}

	public function start() {
		js.node.Http.createServer(app)
		.listen(app.get("port"), function() {
			logger.log('Express started in ' + 
				app.get("env") + ' mode on http://localhost:' + 
				app.get("port") + '; Ctrl+C to terminate.'
			);
		});

		#if ssl
		var options = {
			key: Fs.readFileSync(Node.__dirname + '/ssl/localhost.key'),
			cert: Fs.readFileSync(Node.__dirname + '/ssl/localhost.cert')
		};

		js.node.Https.createServer(options, cast app)
		.listen(app.get("sslPort"), function() {
			logger.log('Express started in ' + 
				app.get("env") + ' mode on https://localhost:' + 
				app.get("sslPort") + '; Ctrl+C to terminate.'
			);
		});
		#end
	}

	#if weather
	private function refreshWeatherData(c) {
		if(!c.refreshing && Date.now().getTime() > 0.0 + c.refreshed + c.updateFrequency) {
			logger.log('Refreshing weather data cache');
			c.refreshing = true;
			var promises = [];
			var locations : Array<WeatherLocation> = c.locations;
			for(loc in locations) {
				logger.log('Refreshing weather for ' + loc.name);
				var def = new Deferred<WeatherLocation>();
				var options = {
					hostname: 'api.wunderground.com',
					path: '/api/' + Credentials.instance.wunderground.apiKey + '/conditions/q/OR/' + loc.name + '.json'
				};

				lib.Request.httpJson(options, function(err, body) {
					loc.forecastUrl = body.current_observation.forecast_url;
					loc.iconUrl = body.current_observation.icon_url;
					loc.weather = body.current_observation.weather;
					loc.temp = body.current_observation.temperature_string;
					def.resolve(loc);
				});

				promises.push(def.promise());
			}

			Promise.whenAll(promises).then(function(_) {
				logger.log('Weather data refreshed.');
				c.refreshing = false;
				c.refreshed = Date.now().getTime();
			});
		}
	}
	#end
}