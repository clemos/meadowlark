Following along the tutorial project in [Web Development with Node and Express](http://shop.oreilly.com/product/0636920032977.do), but using Haxe as language instead of javascript. A work in progress that will evolve using Haxe solutions instead of Node packages. For example, it's using [Buddy](https://github.com/ciscoheat/buddy) for testing instead of mocha and chai.

## Installation

If you're using [Vagrant](http://vagrantup.com), run `vagrant up` and you're set.

If not, make sure that Haxe, Node.js, Git and MongoDB is installed ([provision.sh](https://github.com/ciscoheat/meadowlark/blob/master/provision.sh) can be useful), then run `npm install`.

There are a few haxelib dependencies that will reveal themselves when you compile. But a special one is [js-kit](https://github.com/clemos/haxe-js-kit), a very nice Node.js library for Haxe available only from github. Install with `haxelib git js-kit https://github.com/clemos/haxe-js-kit.git master`.

## Compiling

Compile with `haxe meadowlark.hxml`, then run with `node meadowlark.js` in the `www` directory. Browse to `http://localhost:3000` and it *should* work.
