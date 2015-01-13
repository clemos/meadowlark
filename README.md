## The Meadowlark Travel Website

Following along the project in [Web Development with Node and Express](http://shop.oreilly.com/product/0636920032977.do), but using Haxe as language instead of javascript. A work in progress that will evolve using Haxe solutions instead of Node packages. For example, it's using [Buddy](https://github.com/ciscoheat/buddy) for testing instead of mocha and chai.

**Current progress:** Beginning of Chapter 17.

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

## Grunt - Finally tamed

I hesitated for long before using [Grunt](http://gruntjs.com/), the main reason was the seemingly arbitrary and verbose configuration file. The more I read, the more people praised Grunt and at the same time needed 10-15 pages of explanation how to use it. With almost as many braces as parenthesis in Lisp.

Then I found [this post](http://tbranyen.com/post/coffeescript-has-the-ideal-syntax-for-configurations) about how to use my second-favorite language Coffeescript to configure Grunt. It was supported out of the box simply by naming the Gruntfile `Gruntfile.coffee`. 

So goodbye braces! But it still felt a bit bloated. Loading plugins, registering tasks... It should be simplified with Coffeescript.

First, let's cut down on `grunt` usage. We know it's a Gruntfile, right? So we might as well call it `g`:

```coffeescript
module.exports = (g) ->
```

The biggest code-saver was the [load-grunt-tasks](https://github.com/sindresorhus/load-grunt-tasks) plugin. No more `loadNpmTasks`. And I found a nice execution time plugin, [time-grunt](https://github.com/sindresorhus/time-grunt). Those cannot be auto-loaded by `load-grunt-tasks`, but with Coffeescript it's quite painless:

```coffeescript
module.exports = (g) ->
  require(plugin) g for plugin in ['time-grunt', 'load-grunt-tasks']
  task = g.registerTask
```

And as you see, I've also shortened `registerTask` a little. Now we can get into business with `initConfig` and `task`:

```coffeescript
module.exports = (g) ->
  require(plugin) g for plugin in ['time-grunt', 'load-grunt-tasks']
  task = g.registerTask

  # Reference: http://gruntjs.com/configuring-tasks
  g.initConfig
    less:
      dev:
        files:
          'www/public/css/main.css': 'less/main.less'

  task 'default', ['less']
```

That's it! A final note, if you're using Vagrant on Windows you may get problems with symlinks when installing npm packages (though [this](http://xiankai.wordpress.com/2013/12/26/symlinks-with-vagrant-virtualbox/) may help, or starting Vagrant as an Administrator). Then use `--no-bin-links`, so installing a package may finally look like this:

`sudo npm install --no-bin-links --save-dev grunt-contrib-less`

Thanks to Fintan Boyle for the [grunt-haxe](https://github.com/Fintan/grunt-haxe) plugin.

**Trivia:** In Sweden generally the braces are called "seagull wings". I don't know if it's clever or silly. :)
