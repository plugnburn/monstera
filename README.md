Monstera: tiny web framework with great capabilities
====================================================

**Monstera** (or `monstera.js`) is a very small (under 8.5 KB minified, ~ 3.3 KB minified+gzipped) yet quite powerful microframework that allows you to build reach client-side web apps in a more consistent and a bit easier way.

How to obtain
-------------

You can either download/include ready JS file [here](https://cdn.rawgit.com/plugnburn/monstera/c0421f6e148fa28ed1918861a3ba5547eafacb68/output/monstera.js) or install all the necessary dependencies (Git, Node, NPM and `grunt-cli`) and then run:

```
git clone https://github.com/plugnburn/monstera.git
cd monstera
npm install --save-dev
grunt
```

After that you should see the ready to use file in `output/monstera.js`.

Monstera.DOM
------------

DOM manupulation is the first-priority thing in Monstera. The library provides a convenient shortcut for all frequent operations:

- `Monstera.DOM.ready(callback)` - run a callback on `DOMContentLoaded` event, or immediately if the DOM is ready.
- `Monstera.DOM.load(callback)` - run a callback on `load` event, or immediately if the document is already completely loaded.
- `Monstera.DOM.on(selector, event, callback)` - setup a live `event` listener on any elements matching the `selector` or their descendants. You can specify several events, space-separated. A standard DOM `Event` object is passed to the callback, and the actual element the event is listening on is passed as `this`.
- `Monstera.DOM.off(selector, event)` - remove a live `event` listener for any elements matching the `selector` or their descendants.
- `Monstera.DOM.qS(selector)` - return the first element of the document matching the `selector` (shortcut for `window.document.querySelector`).
- `Monstera.DOM.qSA(selector)` - return a DOM collection of all elements in the document matching the `selector` (shortcut for `window.document.querySelectorAll`).
- `Monstera.DOM.prevent(eventObject)` - a shortcut to prevent any event from its default action and further propagation.
- `Monstera.DOM.getValue(element)` - an easy way to get a value of any DOM element regardless of its semantics (being it a `value` or `innerHTML` physically).
- `Monstera.DOM.setValue(element, value)` - an easy way to set a value on any DOM element regardless of its semantics.

Monstera.Async
--------------

Some basic functionality for non-blocking code loading and execution is built into Monstera:

- `Monstera.Async.nextTick(callback)` - execute the `callback` asynchronously, as soon as possible. Think of it as of in-browser `fork()` functionality.
- `Monstera.Async.load(sourceUrl[, onLoadCallback])` - load an external JavaScript file into the document and fire an optional `onLoadCallback` when the file is loaded (**not when its execution is complete**, just when it's loaded).
- `Monstera.Async.loadAndExpect(sourceUrl, globalObjectName, callback)` - load an external JavaScript file into the document and fire the `callback` when an object with `globalObjectName` becomes available in the global scope (`window`). If such an object already exists, no script is loaded and callback is run immediately.

For example, the following code tries to load [Mustache.js](https://github.com/janl/mustache.js) from an external resource and runs the initialization (see Monstera.Templates section) only when it's fully loaded:

```
var mustacheUrl = '//cdn.rawgit.com/janl/mustache.js/cd06b22dabdaeffe3e4c74ee02bd492a11bbb740/mustache.min.js'
Monstera.Async.loadAndExpect(mustacheUrl, 'Mustache', function() {
	Monstera.Templates.setupRenderer(Mustache.render)
	// ... other templating stuff here ...
})
```

Monstera.Routes
---------------

Client-side routing is an important task for a modern web app. Monstera microframework offers a very simple yet powerful routing capabilities with just 3 methods:

- `Monstera.Routes.add(path, handler)` - define a route. Parameters in the `:param` form are recognized too. Their values are passed in an object to the handler function.
- `Monstera.Routes.remove(path)` - remove a previously defined route (use the same path you have used for `Monstera.Routes.add`).
- `Mostera.Routes.go(path[, preventHistoryUpdates = false])` - go to a path, i.e. perform all actions as if the user entered the path in his browser. If the second parameter `preventHistoryUpdates` is true, the browser will not insert a new history entry.

Monstera.Data
-------------

Monstera provides its own persistent (or session-wide, at your choice) object data storage. This is by far the most powerful and versatile component in the microframework.

### Monstera.Data.Store

The `Monstera.Data.Store` type is the building block of the storage system. You can easily create an instance by supplying a key:

`var MyStore = Monstera.Data.Store('MyApp')`

Alternatively, you can also use a `session:` prefix to create a session-wide storage:

`var MyStore = Monstera.Data.Store('session:MyApp')`

Note that you cannot have a persistent and session storage instances at the same time under the same key. One will overwrite another if you try to do so.

Once you've created the storage object, you can use it just like any other JavaScript object - write/read properties, nest them etc. But if you want your changes to persist, you must call `save()` method like this:

```
MyStore.myProp = 'some value'
MyStore.save()
```


Each `Monstera.Data.Store` instance can have unlimited subscriptions. A subscription is a callback that runs on each `save()` for that storage. To subscribe for a change, just call `subscribe(callback)` method:

`var subscriptionId = MyStore.subscribe(function(){doSomethingElse(this.importantStuff)})`

As you can see, there are two noticeable features:

- the `Monstera.Data.Store` instance is passed as `this` to the callback;
- a subscription ID is returned as a result.

We need the subscription ID in case we need to `unsubscribe()` from storage changes: 

`MyStore.unsubscribe(subscriptionId)`

Lastly, any storage object can be destroyed. To do that, just call the `destroy()` method:

`MyStore.destroy()`

The object reference itself may persist in memory (due to JS engine limitations) but the destruction means that:

- internal (in-memory) storage representation will be cleared;
- all properties will become unavailable, so essentially the object will be no longer useful as a `Monstera.Data.Store` instance.

### Dynamic DOM data binding

You can bind any existing first-level storage property to any DOM element value or contents (the necessary property is determined automatically depending on the element). Just write `YourStorageKey.YourProperty` into a `data-dyna-store` attribute. For example, to make auto-changes to a name property of your user data just modify your input tag:

`<input type=text name=user placeholder="User name" data-dyna-store="User.name">`

Or you can even output it in the real time:

`<p>User name: <span data-dyna-store="User.name"></span></p>`

Note that you have to make at least one reference to the collection in your scripts before you can use this feature. For the above example to work, even this will do:

`<script>Monstera.Data.Store('User')</script>`

If you create a session storage (`Monstera.Data.Store('session:User')`), there is no need to write `session:` prefix in your `data-dyna-store` attribute, the storage engine will be recognized automatically.

### Remote storage

Since version 0.4, Monstera also provides an additional storage type prefix, `remote:`. Remote storage instances differ from persistent and session instances in the following two ways: first, they are effectively read-only at the client side; second, they are initialized with more parameters:

`var remStore = Monstera.Data.Store('remote:MyRemoteApi', {url: '//example.com/api.json', interval: 2500})`

As you can see, any remote storage initializer accepts 2 parameters: a key with `remote:` prefix and an options object with the following possible keys:

- `url` (mandatory) - a remote URL that provides some JSON data;
- `interval` (optional) - an interval (in millisecnods) of repeating remote server queries. If omitted, the URL is queried every 1 second.

You cannot write to a remote storage (well, you can but all properties are completely overwritten on each remote change), while all reading functionality still remains: you can read properties at any time, `subscribe()` to the storage changes and even set up the `data-dyna-store` binding, all the previous rules apply. For example, you have the following JSON file on your server:

`{"USDinUAH": 25.5, "EURinUAH": 30.4}`

Then you can write in your markup:

```
<p>USD rate: <span data-dyna-store="ExchangeRates.USDinUAH"></span> UAH</p>
<p>EUR rate: <span data-dyna-store="ExchangeRates.EURinUAH"></span> UAH</p>
```

And then set up a script with the initializer:

`<script>Monstera.Data.Store('remote:ExchangeRates', {url:'/our-exchange-rates.json'})</script>`

And the above rates will update locally whenever remote JSON file changes.

Monstera.REST
-------------

All basic interaction with server-side is simplified for you. Monstera has all popular HTTP method shortcuts:

- `Monstera.REST.get(url, callback[, errorCallback])`
- `Monstera.REST.getRaw(url, callback[, errorCallback])`
- `Monstera.REST.post(url, object, callback[, errorCallback])`
- `Monstera.REST.postRaw(url, rawData, callback[, errorCallback])`
- `Monstera.REST.put(url, object, callback[, errorCallback])`
- `Monstera.REST.delete(url, callback[, errorCallback])`

All success callbacks accept a single parameter: response data object. Error callbacks, if specified, accept two parameters: response data object and HTTP status code.

By default, all request (for `POST` and `PUT` methods) and response (for all methods) data objects are automatically JSON-serialized and deserialized. However, for `GET` and `POST` methods you can also use `Monstera.REST.getRaw` and `Monstera.REST.postRaw` calls. They imply no JSON marshaling and operate raw text data both as the request and the response.

Monstera.Templates
------------------

Contrary to your expectations after reading the title, Monstera microframework **does not** provide or include any templating engine itself. But its `Monstera.Templates` module makes much more easier not only to integrate any existing client-side templating but also to organize the seamless interoperability of your data and its presentation.

### Setting up

Two important methods are responsible for setting up `Monstera.Templates`: `setupFetcher` and `setupRenderer`.

By default, `Monstera.Templates` module fetches template source code from your server. `Monstera.Templates.setupFetcher` method is for those who want to **optionally** override this behaviour and want, for example, to retrieve template sources from local `<template>` tags and so on. You just have to provide your own function with 2 arguments to `Monstera.Templates.setupFetcher`: the first argument is a template path string, the second is the callback where fetched code will be returned. For example, code to fetch your templates from local `<template>` tags might be the following:

```
Monstera.Templates.setupFetcher(function(tplName, callback) {
	var tplElem = Monstera.DOM.qS('template[name="' + tplName + '"]')
	callback(tplElem ? tplElem.innerHTML : '')
})
```

Easy, right? But the second method, `Monstera.Templates.setupRenderer`, is much more significant and must be called properly in order for entire templating system to work. This is where you bind `Monstera.Templates` module with the actual templating engine of your choice.

It also accepts one function with the following two parameters: template content and passed object with variables. Based on them, it must return a ready-to-output HTML string. For example, let's register a [Mustache.js](https://github.com/janl/mustache.js) renderer (without partials support):

```
Monstera.Templates.setupRenderer(function(tplContent, params) {
	return Mustache.render(tplContent, params)
})
```

But as we see that callback parameters are matching actual renderer parameters, we can strip it down to:

`Monstera.Templates.setupRenderer(Mustache.render)`


Simple as that.

### Rendering

Once you have chosen the way to fetch and write your templates and included the necessary templating engine alongside Monstera, everything else is really a piece of cake. `Monstera.Templates` allows you to **reactively** render any templates based on your data storage instances. So you call this just once for each template to get up and running:

`Monstera.Templates.render(selector, templatePathOrName, storeInstance)`

That's it! Once your `Monstera.Data.Store` instance is saved, the template will be automagically refreshed with your new data on any element matching the `selector`. And if you have event listeners set up with `Monstera.DOM.on`, you will never lose them after template refreshing, nor you'll get any duplicates whatsoever. That's where different framework components perform together very well.

If you need, for whatever reason, just to render a template with parameters into a string (but not bother fetching it and calling the underlying engine directly), you can use `renderText` method:

`Monstera.Templates.renderText(templatePathOrName, params, callback)`

And it will just return rendered HTML into the callback.

Addons
------

Have you seen an empty `src/addons/` directory if you have cloned the repo? It's right for you. You can place any single `*.coffee` file there (in any nested directory structure if you wish) and it will be built into the `output/monstera.js` file as an addon ready to be distributed alongside the core framework. This way you can extend Monstera functionality building on top of its features. Create a pull request when you think your addon is ready for sharing with the world, and all useful addons will be included in this repo.
