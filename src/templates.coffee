do ->
	
	renderer = (tplContent, params) -> tplContent #void renderer by default
	fetcher = (tplPath, cb) ->
		MonsteraLib.REST.getRaw tplPath, (tplContent) ->
			if tplContent?
				cb tplContent
			
	subscriptionCache = {}
	
	templates =
		setupRenderer: (cb) -> renderer = cb
		setupFetcher: (cb) -> fetcher = cb
		renderText: (tplPath, params, cb) ->
			fetcher tplPath, (tplContent) ->
				cb renderer tplContent, params
		render: (domSelector, tplPath, store) ->
			do actualRenderer = (sel = domSelector, tpl = tplPath, params = store) ->
				MonsteraLib.DOM.ready ->
					if elems = MonsteraLib.DOM.qSA sel
						fetcher tplPath, (tplContent) ->
							outputHtml = renderer tplContent, params
							for elem in elems
								elem.innerHTML = outputHtml
			tSubId = "#{tplPath}###{store.key}"
			unless subscriptionCache[tSubId]?
				subscriptionCache[tSubId] = store.subscribe ->
					actualRenderer domSelector, tplPath, this
		

	MonsteraLib.Templates = templates