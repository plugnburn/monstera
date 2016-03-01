grunt = require 'grunt'

grunt.initConfig
	coffee:
		options:
			bare: true
		compile:
			files:
				'temp/monstera-dev.js': [
					'src/init.coffee'		# global initialization
					'src/polyfills.coffee'	# some important polyfills
					'src/dom.coffee'		# Monstera.DOM
					'src/rest.coffee'		# Monstera.REST
					'src/routes.coffee'		# Monstera.Routes
					'src/data.coffee'		# Monstera.Data
					'src/templates.coffee'	# Monstera.Templates
					'src/exporter.coffee'	# final export
				]
				'temp/monstera-addons.js': ['src/addons/**/*.coffee']
	uglify:
		monstera:
			options:
				screwIE8: true
				reserveDOMProperties: true
				wrap:true
			mangle:
				except:['window', 'document', 'Monstera', 'DOM', 'REST', 'Templates', 'Routes', 'Data']
			files:
				'output/monstera.js': ['temp/monstera-dev.js', 'temp/monstera-addons.js']
	
grunt.loadNpmTasks 'grunt-contrib-coffee'
grunt.loadNpmTasks 'grunt-contrib-uglify'

grunt.registerTask 'default', ['coffee:compile', 'uglify:monstera']