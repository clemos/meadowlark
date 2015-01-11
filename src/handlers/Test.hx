package handlers;

import js.Error;
import js.Node;
import js.npm.express.Request;
import js.npm.express.Response;

class Test
{
	public function new() {}

	public function nurseryRhyme(req : Request, res : Response) {
		res.json({
			animal: 'squirrel',
			bodyPart: 'tail',
			adjective: 'bushy',
			noun: 'h3ck',
		});
	}

	public function epicFail(req : Request, res : Response) {
		Node.process.nextTick(function(){
			throw new Error('Kaboom!');
		});
	}
}