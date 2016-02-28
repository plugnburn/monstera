do ->
	evcache = {}
	genEventKey = (selector, evtype) -> selector+'#'+evtype

	dom =
		ready: (cb) ->
			if document.readyState in ['interactive', 'complete']
				cb()
			else
				window.addEventListener 'DOMContentLoaded', cb, false
		load: (cb) ->
			if document.readyState is 'complete'
				cb()
			else
				window.addEventListener 'load', cb, false
		on: (selector, evtype, cb) ->
			for evname in evtype.split ' '
				evkey = genEventKey selector, evname
				evcache[evkey] = (e) ->
					if targetElem = e.target.closest selector
						cb e, targetElem
				window.addEventListener evname, evcache[evkey], false
		off: (selector, evtype) ->
			for evname in evtype.split ' '
				evkey = genEventKey selector, evname
				if evcache[evkey]?
					window.removeEventListener evname, evcache[evkey]
					delete evcache[evkey]
		qS: (s) -> document.querySelector s
		qSA: (s) -> document.querySelectorAll s
		prevent: (e) ->
			e.preventDefault()
			e.stopPropagation()
		setupDropzone: (selector, cb) ->
			elem = dom.qS selector
			elem.addEventListener 'dragover', (e) ->
				dom.prevent e
				e.dataTransfer.effect = 'copy'
			, false
			elem.addEventListener 'drop', (e) ->
				dom.prevent e
				cb e
			, false

	MonsteraLib.DOM = dom