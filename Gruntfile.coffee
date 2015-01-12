module.exports = (g) -> 
	['time-grunt', 'load-grunt-tasks'].forEach (t) -> require(t) g
	task = g.registerTask

	@initConfig
		haxe:
			development:
				hxml: 'meadowlark-all.hxml'

		"link-checker":
			development:
				site: "localhost"
				options:
					initialPort: 3000
					callback: (crawler) ->
						crawler.addFetchCondition (url) ->
							not url.path.match /\/jquery.+\.js$/
		exec:
			tests:
				cmd: 'node www/qa/tests-crosspage.js'

		less:
			development:
				files:
					'www/public/css/main.css': 'less/main.less'
				options:
					customFunctions:
						static: (lessObject, name) ->
							'url("' + require('./www/meadowlark.js').Static.map(name.value) + '")'

	task 'default', ['haxe', 'less', 'exec', 'link-checker']
	task 'build', ['haxe', 'less']
	task 'tests',   ['exec', 'link-checker']
