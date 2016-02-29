do ->
	routeCache = {}
	
	# get route path (i.e. everything after the hostname and port in current location)
	getRoutePath = () -> window.location.pathname + window.location.search + window.location.hash
	
	routes = 
		go: (path, preventHistoryUpdates = false) ->
			for formalPath, cacheObj of routeCache
				if matchList = path.match cacheObj.regex
					matchList.shift()
					params = {}
					for param in cacheObj.params
						params[param] = matchList.shift()
					unless preventHistoryUpdates
						window.history.pushState {}, '', path
					return cacheObj.handler params
		add: (path, cb) ->
			cacheObj =
				params: []
				handler: cb
			regexString = path.replace /\//g, '\\/'
			if (paramMatches = path.match /:([^/]+)/ig)?
				for rawParam in paramMatches
					cacheObj.params.push rawParam.substr(1)
					regexString = regexString.replace rawParam, '([^/]+)'
			cacheObj.regex = new RegExp regexString, 'i'
			routeCache[path] = cacheObj
		remove: (path) ->
			delete routeCache[path]
	
	window.addEventListener 'popstate', (e) ->
		routes.go getRoutePath(), true
	, false
	
	MonsteraLib.DOM.ready ->
		routes.go getRoutePath(), true
		
	MonsteraLib.Routes = routes