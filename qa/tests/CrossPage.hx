package tests;

import buddy.*;
import js.html.InputElement;
import js.Node;
import js.npm.Loadtest;
import js.npm.Mute;
import js.npm.Punt;
import js.npm.Restler;
import js.npm.Zombie;
using buddy.Should;

@:build(buddy.GenerateMain.withSuites([
	new CrossPage(), new StressTest(), new APITests()
]))
class CrossPage extends BuddySuite
{
	public function new() {
		var browser : Zombie;
		var inputField : InputElement;

		describe("Cross-Page Tests", {
			before({
				browser = new Zombie();
			});

			describe("Requesting a Group Rate Quote", {

				describe("From the hood river tour page", {
					it("should populate the referrer field", function(done) {
						var referrer = "http://localhost:3000/tours/hood-river";
						browser.visit(referrer, function() {
							browser.clickLink('.requestGroupRate', function() {
								inputField = cast browser.field('referrer');
								inputField.value.should.be(referrer);
								done();
							});
						});
					});
				});

				describe("From the oregon coast tour page", {
					it("should populate the referrer field", function(done) {
						var referrer = "http://localhost:3000/tours/oregon-coast";
						browser.visit(referrer, function() {
							browser.clickLink('.requestGroupRate', function() {
								inputField = cast browser.field('referrer');
								inputField.value.should.be(referrer);
								done();
							});
						});
					});
				});

				describe("Directly from the Request Group Rate page", {
					it("should result in an empty referrer field", function(done) {
						browser.visit("http://localhost:3000/tours/request-group-rate", function() {
							inputField = cast browser.field('referrer');
							inputField.value.should.be('');
							done();
						});
					});
				});
			});
		});
	}	
}

class StressTest extends BuddySuite
{
	public function new() {
		// For stress testing, we need to shut down console logs, so excluding this test for now.
		@exclude describe("Stress tests", {
			describe("The Homepage", {
				it("should handle 100 requests per second", function(done) {
					var options = {
						url: 'http://localhost:3000',
						concurrency: 4,
						maxRequests: 100
					};

					LoadTest.loadTest(options, function(err, result) {
						if(err != null) err.should.be(null);
						result.totalTimeSeconds.should.beLessThan(1);
						done();
					});
				});
			});
		});
	}
}

class APITests extends BuddySuite
{
	public function new() {
		describe("API tests", {
			this.timeoutMs = 500;

			var attraction = {
				lat: 45.516011,
				lng: -122.682062,
				name: 'Portland Art Museum',
				description: 'Founded in 1892, the Portland Art Museum\'s colleciton ' +
					'of native art is not to be missed.  If modern art is more to your ' +
					'liking, there are six stories of modern art for your enjoyment.',
				email: 'test@meadowlarktravel.com',
			};

			var base = "http://localhost:3000";

			it("should be able to add an attraction", function(done) {
				Restler.post(base + '/api/attraction', {data: attraction})
				.on('error', fail)
				.on('success', function(data) {
					var id : String = data.id;
					id.should.match(~/\w/);
					done();
				});
			});

			it('should be able to retrieve an attraction', function(done) {
				Restler.post(base + '/api/attraction', {data:attraction})
				.on('error', fail)
				.on('success', function(data) {
					Restler.get(base + '/api/attraction/' + data.id)
					.on('error', fail)
					.on('success', function(data) {
						attraction.name.should.be(data.name);
						attraction.description.should.be(data.description);
						done();
					});
				});
			});
		});
	}
}