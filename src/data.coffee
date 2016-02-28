class MonsteraStoreAdapter
	constructor: (setter, getter, remover) ->
		@set = setter
		@get = getter
		@remove = remover

class MonsteraStore

	constructor: (key, adapter = MonsteraLib.Data.LocalStorageAdapter) ->
		Object.defineProperty this, 'key', {configurable: true, writable: true, value: key}
		Object.defineProperty this, 'adapter', {configurable: true, writable: true, value: adapter}
		Object.defineProperty this, 'internalObject', {configurable: true, writable: true, value: {}}
		Object.defineProperty this, 'subscriptions', {configurable: true, writable: true, value: {}}
		@sync()
			
	sync: () ->
		@internalObject = @adapter.get(@key)
		@internalObject = {} unless @internalObject
		for own prop, val of @internalObject
			@[prop] = val
		for own subId, cb of @subscriptions
			cb.call @
		true

	save: () ->
		@internalObject = {}
		for own prop, val of this
			@internalObject[prop] = val
		@adapter.set @key, @internalObject
		for own subId, cb of @subscriptions
			cb.call @
		true
		
	subscribe: (cb) ->
		loop
			subId = "monstera-sub-#{Math.random()*10000|0}"
			break unless @subscriptions[subId]?
		@subscriptions[subId] = cb
		subId
	
	unsubscribe: (subId) -> delete @subscriptions[subId] if @subscriptions[subId]?
	
	destroy: () ->
		@adapter.remove @key
		@adapter = null
		@key = null
		@internalObject = null
		@subscriptions = null
		delete @subscriptions
		delete @key
		delete @internalObject
		delete @adapter
		for own prop, val of this
			delete this[prop]
		delete this


MonsteraLib.Data =
	Store: MonsteraStore
	Adapter: MonsteraStoreAdapter
	
MonsteraLib.Data.LocalStorageAdapter = new MonsteraLib.Data.Adapter ((key, value) -> try window.localStorage.setItem "monstera.#{key}", JSON.stringify(value)),
	((key) -> try JSON.parse window.localStorage.getItem "monstera.#{key}")
	((key) -> try window.localStorage.removeItem "monstera.#{key}")