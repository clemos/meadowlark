package js.npm.nodemailer;

//extern class Transport
typedef Transport = {
	var name : String;
	var version : String;
	function send(mail : Dynamic, callback : Dynamic -> Dynamic -> Void) : Void;
}
