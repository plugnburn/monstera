do ->
	
	methodFilters = {}
	
	do resetMethodFilters = ->
		jsonContentType = 'application/json;charset=utf-8'
		methodFilters =
			get:
				request: (s) -> s
				response: (s) -> JSON.parse s
			post:
				request: (s, xhr) -> 
					xhr.setRequestHeader 'Content-Type', jsonContentType
					JSON.stringify s
				response: (s) -> JSON.parse s
			put:
				request: (s, xhr) -> 
					xhr.setRequestHeader 'Content-Type', jsonContentType
					JSON.stringify s
				response: (s) -> JSON.parse s
			'delete':
				request: (s) -> s
				response: (s) -> JSON.parse s
	
	
	internalAjaxCall = (url, method, rawData, cb, errCb = null) ->
		lMethod = method.toLowerCase()
		xhr = new XMLHttpRequest
		xhr.open method, url, true
		xhr.onload = ->
			realResponse = null
			try realResponse = methodFilters[lMethod].response(xhr.responseText)
			if xhr.status is 200
				cb realResponse
			else if errCb?
				errCb realResponse, xhr.status
		realRequest = rawData
		try realRequest = methodFilters[lMethod].request(rawData, xhr)
		xhr.send realRequest
		
	setupMethodFilters = (method, requestFilter, responseFilter) ->
		method = method.toLowerCase()
		if methodFilters[method]?
			methodFilters[method].request = requestFilter
			methodFilters[method].response = responseFilter
		true
	
	rest = 
		get: (url, cb, errCb = null) -> internalAjaxCall url, 'GET', null, cb, errCb
		post: (url, obj, cb, errCb = null) -> internalAjaxCall url, 'POST', obj, cb, errCb
		put: (url, obj, cb, errCb = null) -> internalAjaxCall url, 'PUT', obj, cb, errCb
		'delete': (url, cb, errCb = null) -> internalAjaxCall url, 'DELETE', null, cb, errCb
		setupMethodFilters: setupMethodFilters
		resetMethodFilters: resetMethodFilters
	
	MonsteraLib.REST = rest