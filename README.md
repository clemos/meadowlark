## The Meadowlark Travel Website

Following along the project in [Web Development with Node and Express](http://shop.oreilly.com/product/0636920032977.do), but using Haxe as language instead of javascript. A work in progress that will evolve using Haxe solutions instead of Node packages. For example, it's using [Buddy](https://github.com/ciscoheat/buddy) for testing instead of mocha and chai.

**Current progress:** Beginning of Chapter 20.

### Todo 

* Chapter 8: Skipped the jQuery File Upload example.

## Installation

If you're using [Vagrant](http://vagrantup.com), run `vagrant up` and you're set.

If not, make sure that Haxe, Node.js, Grunt, Git, and MongoDB is installed ([provision.sh](https://github.com/ciscoheat/meadowlark/blob/master/provision.sh) can be useful), then run `npm install`.

There are a few haxelib dependencies that will reveal themselves when you compile. But a special one is [js-kit](https://github.com/clemos/haxe-js-kit), a very nice Node.js library for Haxe available only from github. Install with `haxelib git js-kit https://github.com/clemos/haxe-js-kit.git dev`. If you get compilation errors, it may not yet be synced with the "bleeding edge" for this project, then you can use `haxelib git js-kit https://github.com/ciscoheat/haxe-js-kit.git dev` on your own risk! :)

If you're using Vagrant on Windows you may get problems with symlinks when installing npm packages (though [this](http://xiankai.wordpress.com/2013/12/26/symlinks-with-vagrant-virtualbox/) may help, or starting Vagrant as Administrator). Then use `--no-bin-links`, so installing a package may finally look like this:

`sudo npm install --no-bin-links --save-dev grunt-contrib-less`

## Compiling and Running

Compile with `haxe meadowlark.hxml`, then go to the `www` directory and run with `node meadowlark.js` or `forever -w meadowlark.js`. Then browse to `http://localhost:3000` and it *should* work.

Take a look in `meadowlark.hxml` for some compiler defines that may be interesting to toggle.

## Authentication

No login data for authentication are saved in the project for security reasons, so to use your Gmail and Facebook information, create `www/.env` with the following content:

```
FB_APPID=
FB_APPSECRET=
GMAIL_USER=
GMAIL_PASSWORD=
TWITTER_CONSUMERKEY=
TWITTER_CONSUMERSECRET=
GOOGLE_MAPS_APIKEY=
WUNDERGROUND_APIKEY=
```

Fill in the blanks, and they will be imported with the help of [node-env-file](https://www.npmjs.com/package/node-env-file).

## Tests

The in-browser tests can be run by appending `?test=1` to any page url, for example `http://localhost:3000/about?test=1`. The cross-page tests are executed with the headless browser [Zombie.js](http://zombie.labnotes.org/) and is run from command-line: `node www/qa/tests-crosspage.js` (of course the server has to be running as well.) Or even easier, use `grunt tests`.

## Grunt - Finally tamed

[Read how the Gruntfile became manageable](https://github.com/ciscoheat/meadowlark/wiki/A-manageable-Gruntfile)

## Thanks

Thanks to Fintan Boyle for the [grunt-haxe](https://github.com/Fintan/grunt-haxe) plugin, and of course to all the plugin authors for making things free and useful.
