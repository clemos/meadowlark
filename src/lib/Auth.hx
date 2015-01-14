package lib;

import js.npm.connect.support.Middleware.MiddlewareNext;
import js.npm.Express;
import js.npm.express.Request;
import js.npm.express.Response;
import js.npm.Passport;
import js.npm.passport.FacebookStrategy;
import models.User;
import models.User.UserManager;

typedef AuthOptions = {
	providers: Dynamic,
	?successRedirect: String,
	?failureRedirect: String
}

class Auth
{
	var app : Express;
	var options : AuthOptions;
	var users : UserManager;

	public function new(app, options : AuthOptions) {
		this.app = app;
		this.options = options;
		this.users = User.build();

		if(options.successRedirect == null)
			options.successRedirect = '/account';

		if(options.failureRedirect == null)
			options.failureRedirect = '/login';
	}

	public function init() {
		var env = app.get('env');
		var config = options.providers;

		Passport.serializeUser(function(user, done) {
			done(null, user._id);
		});

		Passport.deserializeUser(function(id, done) {
			users.findById(id, function(err, user) {
				if(err != null || user == null) return done(err, null);
				done(null, user);
			});
		});

		Passport.use(new FacebookStrategy({
			clientID: Reflect.field(config.facebook, env).appId,
			clientSecret: Reflect.field(config.facebook, env).appSecret,
			callbackURL: '/auth/facebook/callback'
		}, function(accessToken, refreshToken, profile, done) {
			var authId = 'facebook:' + profile.id;
			users.findOne({authId: authId}, function(err, user) {
				if(err != null) return done(err, null);
				if(user != null) return done(null, user);

				var d = Date.now();
				var newUser = users.construct({
					authId: authId,
					name: profile.displayName,
					created: d,
					role: 'customer'
				});
				newUser.save(function(err, _) {
					if(err != null) return done(err, null);
					done(null, newUser);
				});
			});
		}));

		app.use(Passport.initialize());
		app.use(Passport.session());
	}

	public function registerRoutes() {
		app.get('/auth/facebook', function(req, res, next) {
			var middleware : Request->Response->MiddlewareNext->Void = Passport.authenticate('facebook', cast {
				callbackURL: '/auth/facebook/callback' //?redirect=' + StringTools.urlEncode(req.query.redirect)
			});

			middleware(req, res, next);
		});

		app.get('/auth/facebook/callback', [
			Passport.authenticate('facebook', { failureRedirect: options.failureRedirect }), 
			function(req : Request, res : Response, next) { 
				res.redirect(303, req.query.redirect == null ? options.successRedirect : req.query.redirect);
			}
		]);
	}
}