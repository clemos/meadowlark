package js.npm;

import js.npm.nodemailer.Transport;
import js.npm.nodemailer.Transporter;

extern class Nodemailer
implements npm.Package.Require<"nodemailer", "~1.3.0">
{
	@:overload(function() : Transporter {})
	@:overload(function(transport : Transport) : Transporter {})
	public static function createTransport(options : Dynamic) : Transporter;
}
