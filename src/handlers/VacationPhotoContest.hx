package handlers;

import js.Error;
import js.Node;
import js.node.Fs;
import js.npm.connect.support.Middleware;
import js.npm.express.BodyParser;
import js.npm.express.Request;
import js.npm.express.Response;
import js.npm.express.Session;
import js.npm.Formidable.IncomingForm;
import js.npm.mongoose.Mongoose;

class VacationPhotoContest
{
	var console : js.node.stdio.Console;
	var vacationPhotoDir : String;

	public function new() {
		this.console = Node.console;
		this.vacationPhotoDir = Node.__dirname + "/data/vacation-photo";
	}

	public function vacationPhoto(req : Request, res : Response) {
		var now = Date.now();
		res.render('contest/vacation-photo', {
			year: now.getFullYear(), month: now.getMonth()
		});
	}

	public function vacationPhotoSumbission(req : Request, res : Response) {
		IncomingForm().parse(req, function(err, fields, photos) {
			var session = Session.session(req);
			var photo = photos.photo;

			if(err) {
				session.flash = {
					type: 'danger',
					intro: 'Oops!',
					message: 'There was an error processing your submission. ' +
						'Please try again.'
				};
				return res.redirect(303, '/contest/vacation-photo');
			}

			var dir = vacationPhotoDir + '/' + Date.now().getTime();
			var path = dir + '/' + photo.name;
			
			Fs.mkdirSync(dir);

			// /tmp uses a different partition and filesystem.
			// need to copy and unlink: http://stackoverflow.com/a/4571377/70894
			var is = Fs.createReadStream(photo.path);
			var os = Fs.createWriteStream(path);

			is.pipe(os);
			is.on('end', Fs.unlinkSync.bind(photo.path));

			saveContestEntry('vacation-photo', fields.email, req.params.year, req.params.month, path);

			session.flash = {
				type: 'success',
				intro: 'Good luck!',
				message: 'You have been entered into the contest.'
			};

			res.redirect(303, '/contest/vacation-photo/entries');
		});	
	}

	function saveContestEntry(contestName, email, year, month, photoPath) {
		// TODO
	}
}