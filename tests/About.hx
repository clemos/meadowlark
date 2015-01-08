package ;

import buddy.*;
import jQuery.*;

using buddy.Should;

@:build(buddy.GenerateMain.withSuites([
	new About()
]))
class About extends BuddySuite
{
	public function new() {
		describe('About page', {
			it("should contain link to contact page", {
				new JQuery('a[href="/contact"]').length.should.not.be(0);
			});
		});
	}
}
