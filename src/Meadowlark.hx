package;

import handlers.*;
import handlers.api.*;
import haxe.Timer;
import js.Node;
import js.node.Cluster;
import js.node.Domain;
import js.node.Fs;
import js.node.http.Server;
import js.node.Process;
import js.node.stdio.Console;
import js.npm.connect.ConnectRest;
import js.npm.Express;
import js.npm.ExpressHandlebars;
import js.npm.express.Compression;
import js.npm.express.CookieParser;
import js.npm.express.Cors;
import js.npm.express.ErrorHandler;
import js.npm.express.MongooseSession;
import js.npm.express.Morgan;
import js.npm.express.Session;
import js.npm.express.BodyParser;
import js.npm.express.Request;
import js.npm.express.Response;
import js.npm.express.Static;
import js.npm.Nodemailer;
import js.npm.nodemailer.Transporter;

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
		app = new Express();
		logger = Logger.instance;
		Database.connect(app);

		var env = Node.process.env;

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

		app.set('port', env.PORT != null ? env.PORT : 3000);

		///// Mailer /////

		mailer = Nodemailer.createTransport({
			service: 'gmail',
			auth: {
				user: Credentials.gmail.user,
				pass: Credentials.gmail.password
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

					server.close();

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

		app.use(new Compression());
		app.use(new Static(Node.__dirname + '/public'));
		app.use(BodyParser.urlencoded({extended: true}));
		app.use(new CookieParser(Credentials.cookieSecret));
		app.use(new Session({
			secret: Credentials.cookieSecret,
			store: new MongooseSession(Database.instance),
			resave: false,
			saveUninitialized: false
		}));

		///// Tests /////

		app.use(function(req : Request, res : Response, next) {
			res.locals.showTests = app.get('env') != 'production' && req.query.test == '1';
			next();
		});

		///// View Partials /////

		app.use(function(req : Request, res : Response, next) {
			if(!res.locals.partials) res.locals.partials = {};
			res.locals.partials.weather = getWeatherData();
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

		///// Routes /////

		var main = new Main();

		app.get('/', main.home);
		app.get('/about', main.about);

		var vacations = new Vacations();

		app.get('/set-currency/:currency', vacations.setCurrency);
		app.get('/vacations', vacations.vacations);

		var cart = new Cart(mailer);

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

		/// Rest API routes

		var apiOptions = {
			context: '/api',
			domain: Domain.create()
		};

		apiOptions.domain.on('error', function(err) {
			logger.error(err);
			Timer.delay(function() {
				logger.log('Server shutting down after API domain error.');
				Node.process.exit(1);
			}, 5000);
			server.close();
			var worker = Cluster.cluster.worker;
			if(worker != null) worker.disconnect();
		});

		app.use('/api', new Cors());
		app.use(ConnectRest.rester(apiOptions));

		// If you want to use the api subdomain:
		//app.use(new VHost('api.*', ConnectRest.rester(apiOptions)));

		var apiAttractions = new Attractions();

		// Cannot use a function reference directly for ConnectRest!
		ConnectRest.get('/attractions', function(r,c,cb) apiAttractions.get(r,c,cb));
		ConnectRest.get('/attraction/:id', function(r,c,cb) apiAttractions.getById(r,c,cb));
		ConnectRest.post('/attraction', function(r,c,cb) apiAttractions.post(r,c,cb));

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
			logger.error(err);
			res.status(500);
			res.render('500');
		});
	}

	public function start() : Server {
		server = js.node.Http.createServer(app);
		server.listen(app.get("port"), function() {
			logger.log('Express started in ' + 
				app.get("env") + ' mode on http://localhost:' + 
				app.get("port") + '; Ctrl+C to terminate.'
			);
		});

		return server;
	}

	private static function getWeatherData() {
		return {
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
				},
			],
		};
	}
}