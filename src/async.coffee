do (w = window, D = window.document) ->
	nextTickInternal = null
	if w.setImmediate?
		nextTickInternal = w.setImmediate.bind w
	else if w.msSetImmediate?
		nextTickInternal = w.msSetImmediate.bind w
	else if w.Promise?
		resolvedPromiseInternal = w.Promise.resolve()
		nextTickInternal = (cb) -> resolvedPromiseInternal.then cb
	else if w.postMessage?
		msgId = 'AsyncTicker' + Math.random()
		head = {}
		tail = head
		w.addEventListener 'message', (e) ->
			if e.source is w and e.data is msgId
				head = head.next
				task = head.task
				delete head.task
				task()
		, false
		nextTickInternal = (cb) ->
			tail = tail.next = {task: cb}
			w.postMessage msgId, '*'
	else
		nextTickInternal = (cb) -> w.setTimeout cb, 0
	MonsteraLib.Async =
		nextTick: nextTickInternal
		load: (url, cb = null) ->
			el = D.createElement 'script'
			el.src = url
			el.async = true
			if cb?
				if 'onload' of el 
					el.onload = cb
				else el.onreadystatechange = ->
					if el.readyState in ['loaded', 'complete']
						el.onreadystatechange = ->
						cb()
			D.documentElement.appendChild el
		loadAndExpect: (url, objectName, cb) ->
			if w[objectName]?
				cb w[objectName]
			else
				@load url, ->
					do waiter = ->
						if w[objectName]?
							cb w[objectName]
						else nextTickInternal waiter