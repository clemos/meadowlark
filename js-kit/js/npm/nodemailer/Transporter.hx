package js.npm.nodemailer;

extern class Transporter
{
	@:overload(function(data : Dynamic) : Void {})
	@:overload(function(data : Dynamic, callback : Dynamic -> Void) : Void {})
	public function sendMail(data : Dynamic, callback : Dynamic -> Dynamic -> Void) : Void;
}
