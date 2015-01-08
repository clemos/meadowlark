package ;

import buddy.reporting.ConsoleReporter;
import js.Browser;

import buddy.*;
import jQuery.*;

using buddy.Should;

@:build(buddy.GenerateMain.withSuites([new Global()]))
class Global extends BuddySuite
{
	public function new() {
		describe('Global page', {
			it("should have a valid title", {
				var title = Browser.document.title;
				title.should.not.be(null);
				title.should.match(~/\S/);
				title.toUpperCase().should.not.be('TODO');
			});
		});
	}
}
