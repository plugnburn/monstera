do (e = Element.prototype) ->
	# Element.matches polyfill

	e.matches = e.matches or e.webkitMatchesSelector or e.mozMatchesSelector or e.msMatchesSelector or e.oMatchesSelector or (sel) ->
		for elem in (@document or @ownerDocument).querySelectorAll(sel)
			return true if elem is this
		false
	
	# Element.closest polyfill

	e.closest = e.closest or closest = (sel) ->
		if @parentNode
			if @matches sel then this else closest.call @parentNode, sel
		else null