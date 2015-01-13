module.exports = (g) -> 
	require(plugin) g for plugin in ['time-grunt', 'load-grunt-tasks']
	task = g.registerTask

	# Don't start a server when using configuration from the project.
	process.env.NO_SERVER = '1'

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
							not url.path.match /\bjquery.+?\.js\b/

		exec:
			tests:
				cmd: 'node www/qa/tests-crosspage.js'

		less:
			development:
				files:
					'www/public/css/main.css': 'less/main.less'
					'www/public/css/cart.css': 'less/cart.less'
				options:
					customFunctions:
						static: (lessObject, name) ->
							'url("' + require('./www/meadowlark.js').Static.map(name.value) + '")'

		uglify:
			all:
				files:
					'www/public/js/meadowlark.min.js': ['www/public/js/**/*.js']

		cssmin:
			combine:
				files:
					'www/public/css/meadowlark.css': [
						'www/public/css/**/*.css'
						'!www/public/css/meadowlark*.css'
					]
			minify:
				src: 'www/public/css/meadowlark.css'
				dest: 'www/public/css/meadowlark.min.css'

		hashres:
			options:
				fileNameFormat: '${name}.${hash}.${ext}'
			all:
				src: [
					'www/public/js/meadowlark.min.js'
					'www/public/css/meadowlark.min.css'
				]
				dest: [
					'www/meadowlark.js'
				]

		lint_pattern:
			view_statics:
				options:
					rules: [
						pattern: /<link [^>]*href=["'](?!\{\{static )/
						message: 'Un-mapped static resource found in <link>.'
					,
						pattern: /<script [^>]*src=["'](?!\{\{static )/
						message: 'Un-mapped static resource found in <script>.'
					,
						pattern: /<img [^>]*src=["'](?!\{\{static )/
						message: 'Un-mapped static resource found in <img>.'
					]
				files:
					src: [ 'views/**/*.handlebars' ]

			css_statics:
				options:
					rules: [
						pattern: /url\(/
						message: 'Un-mapped static found in LESS property.'
					]

				files:
					src: [ 'less/**/*.less' ]

	task 'default', ['haxe', 'static', 'tests']
	task 'static', ['lint_pattern', 'less', 'cssmin', 'uglify', 'hashres']
	task 'tests',   ['exec', 'link-checker']
