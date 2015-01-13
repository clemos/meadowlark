module.exports = (g) -> 
	require(plugin) g for plugin in ['time-grunt', 'load-grunt-tasks']
	task = g.registerTask

	g.initConfig
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
