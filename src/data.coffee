StorageCache = {}
StorageKeyPrefix = 'monstera.'
DynaStoreAttrName = 'data-dyna-store'

readStorage = (storageObject) ->
	if storageObject.storageEngine?
		physicalKey = StorageKeyPrefix + storageObject.key
		propSet = {}
		try propSet = JSON.parse window[storageObject.storageEngine].getItem physicalKey
		for own prop, val of propSet
			storageObject[prop] = val
	return storageObject

writeStorage = (storageObject) ->
	if storageObject.storageEngine?
		physicalKey = StorageKeyPrefix + storageObject.key
		window[storageObject.storageEngine].setItem physicalKey, JSON.stringify(storageObject)
	
destroyStorage = (storageObject) ->
	if storageObject.storageEngine?
		physicalKey = StorageKeyPrefix + storageObject.key
		window[storageObject.storageEngine].removeItem physicalKey
	
# bind DynaStore listeners to any newly created storage object
# returns storage-to-element subscription id

bindDynaStoreListeners = (key) ->
	DOM = MonsteraLib.DOM
	
	# element-to-storage binding
	elemToStorageHandler = ->
		attr = @getAttribute DynaStoreAttrName
		[storageKey, propName] = attr.split '.'
		StorageCache[storageKey][propName] = DOM.getValue this
		StorageCache[storageKey].save()
	e2sSelPart = '['+DynaStoreAttrName+'^="'+key+'."]'
	DOM.on "input#{e2sSelPart}, textarea#{e2sSelPart}, [contenteditable]#{e2sSelPart}", 'input', elemToStorageHandler
	DOM.on "select#{e2sSelPart}", 'change', elemToStorageHandler
	
	# storage-to-element binding
	StorageCache[key].subscribe ->
		DOM.ready =>
			for own prop, val of this
				if (elemSet = DOM.qSA '['+DynaStoreAttrName+'="'+key+'.'+prop+'"]')?
					DOM.setValue elem, val for elem in elemSet

# populate data for remote storage type

defineRemotePoller = (key, pollingInterval) ->
	do initialPoller = ->
		if StorageCache[key]?
			do networkPoller = ->
				MonsteraLib.REST.get StorageCache[key].remoteUrl, (newData) ->
					stringCache = JSON.stringify(StorageCache[key])
					if JSON.stringify(newData) isnt stringCache
						for own prop, val of JSON.parse(stringCache)
							delete StorageCache[key][prop] 
						for own prop, val of newData
							Object.defineProperty StorageCache[key], prop, {configurable: true, enumerable: true, writable: false, value: val}
						StorageCache[key].save()
					setTimeout networkPoller, pollingInterval
		else
			setTimeout initialPoller, pollingInterval
					
MonsteraLib.Data = 
	Store: (key, storageParams = {}) ->
		unless StorageCache[key]? # create and cache a new storage object
			storageObject =
				save: -> 
					writeStorage this
					for own subId, cb of @subscriptions
						cb.call StorageCache[key]
					this
				subscribe: (cb) ->
					loop
						subId = "monstera-sub-#{Math.random()*10000|0}"
						break unless @subscriptions[subId]?
					@subscriptions[subId] = cb
					@subscriptions[subId].call this
					subId
				unsubscribe: (subId) -> 
					delete @subscriptions[subId] if @subscriptions[subId]?
					this
				destroy: -> 
					destroyStorage this
					delete StorageCache[@key]
					delete this
			if key.indexOf('session:') is 0
				Object.defineProperty storageObject, 'storageEngine', {value: 'sessionStorage'}
				key = key.split(':')[1]
			else if key.indexOf('remote:' is 0) and storageParams.url?
				Object.defineProperty storageObject, 'remoteUrl', {value: storageParams.url}
				pollingInterval = if storageParams.interval? then parseInt(storageParams.interval) else 1000
				if pollingInterval < 100 then pollingInterval = 100
				Object.defineProperty storageObject, 'pollingInterval', {value: pollingInterval}
				key = key.split(':')[1]
				defineRemotePoller key, pollingInterval
			else
				Object.defineProperty storageObject, 'storageEngine', {value: 'localStorage'}
			Object.defineProperty storageObject, 'key', {value: key}
			Object.defineProperty storageObject, 'subscriptions', {configurable: true, writable: true, value: {}}
			StorageCache[key] = readStorage storageObject
			bindDynaStoreListeners key
			for own subId, cb of StorageCache[key].subscriptions
				cb.call StorageCache[key]
			StorageCache[key]
		else	# sync and return an existing storage object
			readStorage StorageCache[key]

window.addEventListener 'storage', (e) ->
	storageKey = e.key.substr StorageKeyPrefix.length
	if StorageCache[storageKey]?
		readStorage StorageCache[key]
		for own subId, cb of StorageCache[storageKey].subscriptions
			cb.call StorageCache[storageKey]
, false