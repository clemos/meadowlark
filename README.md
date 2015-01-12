## The Meadowlark Travel Website

Following along the project in [Web Development with Node and Express](http://shop.oreilly.com/product/0636920032977.do), but using Haxe as language instead of javascript. A work in progress that will evolve using Haxe solutions instead of Node packages. For example, it's using [Buddy](https://github.com/ciscoheat/buddy) for testing instead of mocha and chai.

**Current progress:** Middle of Chapter 16.

### Todo 

* Chapter 8: Skipped the jQuery File Upload example.

## Installation

If you're using [Vagrant](http://vagrantup.com), run `vagrant up` and you're set.

If not, make sure that Haxe, Node.js, Grunt, Git, and MongoDB is installed ([provision.sh](https://github.com/ciscoheat/meadowlark/blob/master/provision.sh) can be useful), then run `npm install`.

There are a few haxelib dependencies that will reveal themselves when you compile. But a special one is [js-kit](https://github.com/clemos/haxe-js-kit), a very nice Node.js library for Haxe available only from github. Install with `haxelib git js-kit https://github.com/clemos/haxe-js-kit.git master`.

## Compiling and Running

Compile with `haxe meadowlark.hxml`, then go to the `www` directory and run with `node meadowlark.js` or `forever -w meadowlark.js`. Then browse to `http://localhost:3000` and it *should* work.

## Tests

The in-browser tests can be run by appending `?test=1` to any page url, for example `http://localhost:3000/about?test=1`. The cross-page tests are executed with the headless browser [Zombie.js](http://zombie.labnotes.org/) and is run from command-line: `node www/qa/tests-crosspage.js` (of course the server has to be running as well.)
