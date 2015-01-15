package js.npm;

import js.node.http.Server;
import js.npm.nodemailer.Transport;
import js.npm.nodemailer.Transporter;

typedef LoadTestResult = {
	totalRequests: Int,
	percentiles: Dynamic,
	rps: Int,
	totalTimeSeconds: Float,
	meanLatencyMs: Float,
	totalErrors: Int,
	errors: Dynamic
}

extern class LoadTest
implements npm.Package.Require<"loadtest", "^1.2.4">
{
	public static function loadTest(options : {}, ?callback : Dynamic -> LoadTestResult -> Void) : Void;
	public static function startServer(options : {}) : Server;
}
