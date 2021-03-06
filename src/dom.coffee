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
						cb.call targetElem, e
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
		getValue: (elem) ->
			tag = elem.tagName.toLowerCase()
			if tag in ['input', 'textarea', 'select']
				elem.value
			else
				elem.innerHTML
		setValue: (elem, value) ->
			tag = elem.tagName.toLowerCase()
			if tag in ['input', 'textarea', 'select']
				elem.value = value
				if tag is 'select' and rightOption = elem.querySelector 'option[value="'+value+'"]'
					rightOption.selected = true
			else
				elem.innerHTML = value

	MonsteraLib.DOM = dom