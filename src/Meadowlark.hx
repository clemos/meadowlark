package;

import haxecontracts.ContractException;
import js.Node;
import js.node.Process;
import js.npm.Express;
import js.npm.express.Compression;
import js.npm.express.CookieParser;
import js.npm.express.Morgan;
import js.npm.express.morgan.MorganFormat;
import js.npm.express.Session;
import js.npm.ExpressHandlebars;
import js.npm.express.BodyParser;
import js.npm.express.Request;
import js.npm.express.Response;
import js.npm.express.Static;
import js.npm.Formidable;
import js.npm.formidable.IncomingForm;

class Meadowlark
{
	public static function main() {
		var env = Node.process.env;
		var app = new Express();

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

		///// Logging /////

		switch(app.get('env')) {
			case 'development':
				app.use(new Morgan(MorganFormat.dev));
			case _:
		}

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

		///// Newsletter /////

		app.get('/newsletter', function(req : Request, res : Response) {
			// we will learn about CSRF later...for now, we just
			// provide a dummy value
			res.render('newsletter', { csrf: 'CSRF token goes here' });
		});

		app.post('/process', function(req : Request, res : Response) {
			var form = BodyParser.body(req);

			Node.console.log('Form (from querystring): ' + req.query.form);
			Node.console.log('CSRF token (from hidden form field): ' + form._csrf);
			Node.console.log('Name (from visible form field): ' + form.name);
			Node.console.log('Email (from visible form field): ' + form.email);

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

		app.post('/contest/vacation-photo/:year/:month', function(req : Request, res : Response) {
			var form = Formidable.IncomingForm();

			form.parse(req, function(err, fields, file : js.npm.formidable.File) {
				if(err) return res.redirect(303, '/error');

				Node.console.log('received fields:');
				Node.console.log(fields);
				Node.console.log('received files:');
				Node.console.log(file);

				res.redirect(303, '/thank-you');
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

		///// Error handling /////

		app.use(function(req : Request, res : Response) {
			res.status(404);
			res.render('404');
		});

		app.use(function(err, req : js.npm.express.Request, res : js.npm.express.Response, next) {
			if(Std.is(err, ContractException)) 
				logContractException(cast err);
			else 
				Node.console.error(err.stack);

			res.status(500);
			res.render('500');
		});

		///// Start /////

		app.listen(app.get("port"), function() {
			Node.console.log('Express started in ' + app.get("env") + ' mode on http://localhost:' + 
				app.get("port") + '; Ctrl+C to terminate.');
		});
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

	private static function logContractException(e : ContractException) {
		Node.console.error("ContractException:");
		Node.console.error(e.message);
		Node.console.error(e.object);
		for (s in e.callStack) switch s {
			case FilePos(s, file, line): Node.console.error('$file:$line');
			case _:
		}
	}

	private static function mailExample() {
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
			if(err) Node.console.error('Unable to send email: ' + err);
		});
	}
}