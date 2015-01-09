package tests;

import buddy.*;
import js.html.InputElement;
import js.npm.Zombie;
using buddy.Should;

@:build(buddy.GenerateMain.withSuites([
	new CrossPage()
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