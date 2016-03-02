do ->
	
	voidf = (s) -> s
	
	defaultMethodFilters =
		get:
			request: voidf
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
			request: voidf
			response: (s) -> JSON.parse s	
	
	internalAjaxCall = (params) -> # url, method, cb, errCb, requestFilter, responseFilter, data
		lMethod = params.method.toLowerCase()
		xhr = new XMLHttpRequest
		xhr.open params.method, params.url, true
		xhr.onload = ->
			realResponse = null
			responseProcessor = if params.responseFilter? then params.responseFilter else defaultMethodFilters[lMethod].response
			try realResponse = responseProcessor xhr.responseText
			if xhr.status is 200 and params.cb?
				params.cb realResponse
			else if params.errCb?
				params.errCb realResponse, xhr.status
		realRequest = params.data
		requestProcessor = if params.requestFilter? then params.requestFilter else defaultMethodFilters[lMethod].request
		try realRequest = requestProcessor rawData, xhr
		xhr.send realRequest
	
	rest = 
		get: (url, cb, errCb = null) -> internalAjaxCall {url, method:'GET', data:null, cb, errCb}
		getRaw: (url, cb, errCb = null) ->
			internalAjaxCall {url, method:'GET', data:null, cb, errCb, responseFilter: voidf}
		post: (url, obj, cb, errCb = null) -> internalAjaxCall {url, method:'POST', data:obj, cb, errCb}
		postRaw: (url, obj, cb, errCb = null) ->
			internalAjaxCall {url, method:'POST', data:obj, cb, errCb, requestFilter: voidf, responseFilter: voidf}
		put: (url, obj, cb, errCb = null) -> internalAjaxCall {url, method:'PUT', data:obj, cb, errCb}
		'delete': (url, cb, errCb = null) -> internalAjaxCall {url, method:'DELETE', data:null, cb, errCb}
	
	MonsteraLib.REST = rest