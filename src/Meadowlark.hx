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
			defaultLayout: 'main'
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