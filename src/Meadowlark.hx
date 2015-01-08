package;

import js.Node;
import js.node.Process;
import js.npm.Express;
import js.npm.express.Request;
import js.npm.express.Response;
import js.npm.express.*;
import js.npm.ExpressHandlebars;

class Meadowlark
{
	public static function main() {
		var fortunes = [
			"Conquer your fears or they will conquer you.",
			"Rivers need springs.",
			"Do not fear what you don't know.",
			"You will have a pleasant surprise.",
			"Whenever possible, keep it simple.",
		];

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

		///// Routes /////

		app.get('/', function(req : Request, res : Response) {
			res.render('home');
		});

		app.get('/about', function(req : Request, res : Response) {
			var randomFortume = fortunes[Std.random(fortunes.length)];
			res.render('about', {
				fortune: randomFortume
			});
		});

		app.use(function(req : Request, res : Response) {
			res.status(404);
			res.render('404');
		});

		app.use(function(err, req : js.npm.express.Request, res : js.npm.express.Response, next) {
			Node.console.error(err.stack);
			res.status(500);
			res.render('500');
		});

		///// Start /////

		app.listen(app.get("port"), function() {
			Node.console.log('Express started on http://localhost:' + app.get("port") + '; Ctrl+C to terminate.');
		});
	}
}