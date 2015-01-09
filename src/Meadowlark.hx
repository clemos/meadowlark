package;

import haxecontracts.ContractException;
import js.Node;
import js.node.Process;
import js.npm.Express;
import js.npm.express.Request;
import js.npm.express.Response;
import js.npm.ExpressHandlebars;

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

		///// Static /////

		app.use(new js.npm.express.Static(Node.__dirname + '/public'));

		///// Tests /////

		app.use(function(req : Request, res : Response, next) {
			res.locals.showTests = app.get('env') != 'production' && req.query.test == '1';
			next();
		});

		///// Partials /////

		app.use(function(req : Request, res : Response, next) {
			if(!res.locals.partials) res.locals.partials = {};
			res.locals.partials.weather = getWeatherData();
			next();
		});

		///// Routes /////

		app.get('/', function(req : Request, res : Response) {
			res.render('home');
		});

		app.get('/about', function(req : Request, res : Response) {
			res.render('about', {
				fortune: FortuneCookies.getFortune(),
				pageTestScript: '/qa/tests-about.js'
			});
		});

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
			Node.console.log('Express started on http://localhost:' + app.get("port") + '; Ctrl+C to terminate.');
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
}