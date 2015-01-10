package;

import haxecontracts.ContractException;
import js.Error;
import js.Node;
import js.node.Fs;
import js.node.http.Server;
import js.node.Process;
import js.node.stdio.Console;
import js.npm.Express;
import js.npm.express.Compression;
import js.npm.express.CookieParser;
import js.npm.express.ErrorHandler;
import js.npm.express.Morgan;
import js.npm.express.Session;
import js.npm.ExpressHandlebars;
import js.npm.express.BodyParser;
import js.npm.express.Request;
import js.npm.express.Response;
import js.npm.express.Static;
import js.npm.Formidable;
import js.npm.formidable.IncomingForm;
import models.Vacation;
import models.Vacation.VacationManager;

class Meadowlark
{
	var server : Server;
	var app : Express;
	var console : Console;

	public static function main() {
		#if cluster
		new MeadowlarkCluster().start();
		#else
		new Meadowlark().start();
		#end
	}

	public function new() {
		app = new Express();
		console = Node.console;

		var env = Node.process.env;

		var handlebars = ExpressHandlebars.create({
			defaultLayout: 'main',
			helpers: {
				section: function(name : String, options : Dynamic) {
					var self = untyped __js__('this');
					if(self._sections == null) self._sections = {};
					Reflect.setField(self._sections, name, options.fn(self));
					return null;
				}
			}
		});

		app.engine('handlebars', handlebars.engine);
		app.set('view engine', 'handlebars');

		app.set('port', env.PORT != null ? env.PORT : 3000);

		///// Error catching with domains /////

		app.use(function(req : Request, res : Response, next) {
			var domain = js.node.Domain.create();
			domain.on('error', function(err) {
				console.error("DOMAIN ERROR CAUGHT");
				logError(err);
				try {
					haxe.Timer.delay(function() {
						console.error("Failsafe shutdown.");
						Node.process.exit(1);
					}, 5000);

					var worker = js.node.Cluster.cluster.worker;
					if(worker != null) worker.disconnect();

					server.close();

					try {
						next(err);
					} catch(err : Dynamic) {
						// if Express error route failed, try plain Node response
						console.error('Express error mechanism failed.\n');
						logError(err);
						res.statusCode = 500;
						res.setHeader('content-type', 'text/plain');
						res.end('Server error.');						
					}
				} catch(err : Dynamic) {
					console.error('Unable to send 500 response.\n');
					logError(err);
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
					if(cluster.isWorker) console.log('Worker %d received request', cluster.worker.id);
					next();
				});
			case _:
		}

		///// Files and Parsers /////

		app.use(new Compression());
		app.use(new Static(Node.__dirname + '/public'));
		app.use(BodyParser.urlencoded({extended: true}));
		app.use(new CookieParser(Credentials.cookieSecret));
		app.use(new Session({
			secret: Credentials.cookieSecret,
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

		///// Database /////

		var mongoose = js.npm.Mongoose.mongoose;
		var db : js.npm.mongoose.Mongoose;
		var opts = {
			server: {
				socketOptions: { keepAlive: 1 }
			}
		};

		switch(app.get('env')) {
			case 'development':
				db = mongoose.connect(Credentials.mongo.devolopment.connectionString, cast opts);
			case 'production':
				db = mongoose.connect(Credentials.mongo.production.connectionString, cast opts);
			case _:
				throw new Error('Unknown execution environment: ' + app.get('env'));
		}

		var vacation = VacationManager.build(db, "Vacation");

		seedDatabase(db);

		///// Basic routes /////

		app.get('/', function(req : Request, res : Response) {
			res.render('home');
		});

		app.get('/about', function(req : Request, res : Response) {
			res.render('about', {
				fortune: FortuneCookies.getFortune(),
				pageTestScript: '/qa/tests-about.js'
			});
		});

		///// Vacations /////

		app.get('/vacations', function(req : Request, res : Response) {
			vacation.find({available: true}, function(err, vacations) {
				var context = {
					vacations: vacations.map(function(vacation) {
						return {
							sku: vacation.sku,
							name: vacation.name,
							description: vacation.description,
							price: vacation.getDisplayPrice(),
							inSeason: vacation.inSeason
						}
					})
				};

				res.render('vacations', context);
			});
		});

		///// Newsletter /////

		app.get('/newsletter', function(req : Request, res : Response) {
			// we will learn about CSRF later...for now, we just
			// provide a dummy value
			res.render('newsletter', { csrf: 'CSRF token goes here' });
		});

		app.post('/process', function(req : Request, res : Response) {
			var form = BodyParser.body(req);

			console.log('Form (from querystring): ' + req.query.form);
			console.log('CSRF token (from hidden form field): ' + form._csrf);
			console.log('Name (from visible form field): ' + form.name);
			console.log('Email (from visible form field): ' + form.email);

			if(req.xhr || req.accepts('json,html') == 'json'){
				// if there were an error, we would send { error: 'error description' }
				res.send({ success: true });
			} else {
				// if there were an error, we would redirect to an error page
				res.redirect(303, '/thank-you');
			}
		});

		///// Vacation Photos /////

		app.get('/contest/vacation-photo', function(req : Request, res : Response) {
			var now = Date.now();
			res.render('contest/vacation-photo', {
				year: now.getFullYear(), month: now.getMonth()
			});
		});

		function saveContestEntry(contestName, email, year, month, photoPath) {
			// TODO
		}

		app.post('/contest/vacation-photo/:year/:month', function(req : Request, res : Response) {
			var form = Formidable.IncomingForm();
			var vacationPhotoDir = Node.__dirname + '/data/vacation-photo';

			form.parse(req, function(err, fields, photo : js.npm.formidable.File) {
				var session = Session.session(req);
				if(err) {
					session.flash = {
						type: 'danger',
						intro: 'Oops!',
						message: 'There was an error processing your submission. ' +
							'Please try again.'
					};
					return res.redirect(303, '/contest/vacation-photo');
				}

				var dir = vacationPhotoDir + '/' + Date.now();
				var path = dir + '/' + photo.name;
				
				Fs.mkdirSync(dir);
				Fs.renameSync(photo.path, dir + '/' + photo.name);

				saveContestEntry('vacation-photo', fields.email, req.params.year, req.params.month, path);

				session.flash = {
					type: 'success',
					intro: 'Good luck!',
					message: 'You have been entered into the contest.'
				};

				res.redirect(303, '/contest/vacation-photo/entries');
			});
		});

		///// Tours /////

		app.get('/tours/hood-river', function(req : Request, res : Response) {
			res.render('tours/hood-river');
		});

		app.get('/tours/oregon-coast', function(req : Request, res : Response) {
			res.render('tours/oregon-coast');
		});

		app.get('/tours/request-group-rate', function(req : Request, res : Response) {
			res.render('tours/request-group-rate');
		});

		///// Test routes /////

		app.get('/jquery-test', function(req : Request, res : Response) {
			res.render('jquery-test');
		});

		app.get('/nursery-rhyme', function(req : Request, res : Response) {
			res.render('nursery-rhyme');
		});

		app.get('/data/nursery-rhyme', function(req : Request, res : Response) {
			res.json({
				animal: 'squirrel',
				bodyPart: 'tail',
				adjective: 'bushy',
				noun: 'h3ck',
			});
		});

		app.get('/epic-fail', function(req : Request, res : Response) {
			Node.process.nextTick(function(){
				throw new js.Error('Kaboom!');
			});
		});

		///// Error handling /////

		app.use(function(req : Request, res : Response) {
			res.status(404);
			res.render('404');
		});

		app.use(function(err, req : js.npm.express.Request, res : js.npm.express.Response, next) {
			if(Std.is(err, ContractException)) 
				logContractException(cast err);
			else 
				console.error(err.stack);

			res.status(500);
			res.render('500');
		});
	}

	public function start() : Server {
		server = js.node.Http.createServer(app);
		server.listen(app.get("port"), function() {
			console.log('Express started in ' + 
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

	private function logError(err : Dynamic) : Void {
		if(Std.is(err, ContractException)) logContractException(cast err);
		else console.error(err.stack);
	}

	private function logContractException(e : ContractException) {
		console.error("ContractException:");
		console.error(e.message);
		console.error(e.object);
		for (s in e.callStack) switch s {
			case FilePos(s, file, line): console.error('$file:$line');
			case _:
		}
	}

	private function mailExample() {
		js.npm.Nodemailer.createTransport({
			service: 'gmail',
			auth: {
				user: Credentials.gmail.user,
				pass: Credentials.gmail.password
			}
		}).sendMail({
			from: "someone@example.com",
			to: 'receiver@address',
			subject: 'hello',
			text: 'hello world!'
		}, function(err) {
			if(err) console.error('Unable to send email: ' + err);
		});
	}

	private function seedDatabase(db) {
		var vacation = VacationManager.build(db, "Vacation");

		vacation.find(function(err, vacations) {
			if(vacations.length > 0) return;

			vacation.construct({
				name: 'Hood River Day Trip',
				slug: 'hood-river-day-trip',
				category: 'Day Trip',
				sku: 'HR199',
				description: 'Spend a day sailing on the Columbia and ' +
					'enjoying craft beers in Hood River!',
				priceInCents: 9995,
				tags: ['day trip', 'hood river', 'sailing', 'windsurfing', 'breweries'],
				inSeason: true,
				maximumGuests: 16,
				available: true,
				packagesSold: 0
			}).save();

			vacation.construct({
				name: 'Oregon Coast Getaway',
				slug: 'oregon-coast-getaway',
				category: 'Weekend Getaway',
				sku: 'OC39',
				description: 'Enjoy the ocean air and quaint coastal towns!',
				priceInCents: 269995,
				tags: ['weekend getaway', 'oregon coast', 'beachcombing'],
				inSeason: false,
				maximumGuests: 8,
				available: true,
				packagesSold: 0
			}).save();

			vacation.construct({
				name: 'Rock Climbing in Bend',
				slug: 'rock-climbing-in-bend',
				category: 'Adventure',
				sku: 'B99',
				description: 'Experience the thrill of climbing in the high desert.',
				priceInCents: 289995,
				tags: ['weekend getaway', 'bend', 'high desert', 'rock climbing'],
				inSeason: true,
				requiresWaiver: true,
				maximumGuests: 4,
				available: false,
				packagesSold: 0,
				notes: 'The tour guide is currently recovering from a skiing accident.'
			}).save();
		});
	}
}