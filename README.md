Monstera: tiny web framework with great capabilities
====================================================

**Monstera** (or `monstera.js`) is a very small (under 7 KB minified, 2.8 KB minified+gzipped) yet quite powerful microframework that allows you to build reach client-side web apps in a more consistent and a bit easier way.

How to obtain
-------------

You can either download/include ready JS file [here](https://cdn.rawgit.com/plugnburn/monstera/54bb549ff85978c2ad9979d47b9fe579862e7daf/output/monstera.js) or install all the necessary dependencies (Git, Node, NPM and `grunt-cli`) and then run:

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
- `Monstera.DOM.on(selector, event, callback)` - setup a live `event` listener on any elements matching the `selector` or their descendants. You can specify several events, space-separated. Two parameters are passed to the `callback`: a standard DOM `Event` object and the actual element the listener was attached to.
- `Monstera.DOM.off(selector, event)` - remove a live `event` listener for any elements matching the `selector` or their descendants.
- `Monstera.DOM.qS(selector)` - return the first element of the document matching the `selector` (shortcut for `window.document.querySelector`)
- `Monstera.DOM.qSA(selector)` - return a DOM collection of all elements in the document matching the `selector` (shortcut for `window.document.querySelectorAll`)
- `Monstera.DOM.prevent(eventObject)` - a shortcut to prevent any event from its default action and further propagation.
- `Monstera.DOM.setupDropzone(selector, dropCallback)` - an easy way to set up basic drag-n-drop capabilities. Drop event object is passed to the callback.

Monstera.Routes
---------------

Client-side routing is an important task for a modern web app. Monstera microframework offers a very simple yet powerful routing capabilities with just 3 methods:

- `Monstera.Routes.add(path, handler)` - define a route. Parameters in the `:param` form are recognized too. Their values are passed in an object to the handler function.
- `Monstera.Routes.remove(path)` - remove a previously defined route (use the same path you have used for `Monstera.Routes.add`)
- `Mostera.Routes.go(path[, preventHistoryUpdates = false])` - go to a path, i.e. perform all actions as if the user entered the path in his browser. If the second parameter `preventHistoryUpdates` is true, the browser will not insert a new history entry.

Monstera.Data
-------------

Monstera provides own persistent object data storage that can be bound to different adapters. This is by far the most powerful and versatile component in the microframework.

### Monstera.Data.Store

The `Monstera.Data.Store` type is the building block of the storage system. You can easily create an instance by supplying a key to the constructor:

`var MyStore = new Monstera.Data.Store('MyApp')`

If you have written a different adapter (see below), you can pass it as the second parameter. The only pre-installed adapter is `Monstera.Data.LocalStorageAdapter` and it's set up by default, so the above call could also be performed as:

`var MyStore = new Monstera.Data.Store('MyApp', Monstera.Data.LocalStorageAdapter)`

Once you've created the storage object, you can use it just like any other JavaScript object - write/read properties, nest them etc. But if you want your changes to persist, you must call `save()` method like this:

```
MyStore.myProp = 'some value'
MyStore.save()
```

If you use just the default adapter (`Monstera.Data.LocalStorageAdapter`), you will not need the following method, but if you have written an adapter for the remote storage, you must be aware of it. The `sync()` method fetches current storage data, regardless of its source. Remember to save your local data before syncing in order not to get it overwritten!

```
MyStore.myProp = 'some value'
MyStore.save() // we saved myProp to some remote storage
MyStore.sync()
console.log(MyStore.otherProp) // otherProp was set remotely and now we've fetched it
```

Each `Monstera.Data.Store` instance can have unlimited subscriptions. A subscription is a callback that runs on each `save()` or `sync()` for that storage. To subscribe for a change, just call `subscribe(callback)` method:

`var subscriptionId = MyStore.subscribe(function(){doSomethingElse(this.importantStuff)})`

As you can see, there are two noticeable features:

- the `Monstera.Data.Store` instance is passed as `this` to the callback;
- a subscription ID is returned as a result.

We need the subscription ID in case we need to `unsubscribe()` from storage changes: 

`MyStore.unsubscribe(subscriptionId)`

Lastly, any storage object can be destroyed. To do that, just call the `destroy()` method:

`MyStore.destroy()`

The object reference itself may persist in memory (due to JS engine limitations) but the destruction means that:

- physical adapter storage (localStorage, etc) responsible for the instance will be cleared (adapter's remover will be called - see below);
- internal (in-memory) storage representation will be cleared;
- all properties will become unavailable, so essentially the object will be no longer useful as a `Monstera.Data.Store` instance.

### Monstera.Data.Adapter

This is the interface for any new adapters you can create. You just have to provide three callback functions to the constructor: _setter_, _getter_ and _remover_. You can assign a newly created adapter to any object of your choice but `Monstera.Data` namespace itself is just fine for that.

`Monstera.Data.MyOwnAdapter = new Monstera.Data.Adapter(setterFunc, getterFunc, removerFunc)`

Three simple rules apply when creating a new adapter for Monstera.Data:

- Setter callback must accept two parameters: string key and unserialized object.
- Getter and remover callbacks must accept string key parameter only.
- Getter must return an unserialized object.

Everything else is really up to you.


Monstera.REST
-------------

All basic interaction with server-side is simplified for you. First of all, Monstera has 4 popular HTTP method shortcuts:

- `Monstera.REST.get(url, callback[, errorCallback])`
- `Monstera.REST.post(url, object, callback[, errorCallback])`
- `Monstera.REST.put(url, object, callback[, errorCallback])`
- `Monstera.REST.delete(url, callback[, errorCallback])`

All success callbacks accept a single parameter: response data object. Error callbacks, if specified, accept two parameters: response data object and HTTP status code.

By default, all request (for `POST` and `PUT` methods) and response (for all methods) data objects are automatically JSON-serialized and deserialized. However, you can override this behaviour at any time for any method by calling `Monstera.REST.setupMethodFilters` function. It has the following syntax:

`Monstera.REST.setupMethodFilters(method, requestFilterFunction, responseFilterFunction)`

Here, `method` is the HTTP method whose behavoiur we're changing.

`requestFilterFunction` is the function that specifies what to do with the input data before they're actually sent. It accepts two parameters - raw data and `XMLHttpRequest` object - and must return processed data.

Similarly, `responseFilterFunction` is the function that specifies what to do with the response data before they're returned to the callback, and accepts only one parameter.

For example, if we want to set up `POST` requests to deal with raw data only, without any JSON marshaling, we can call:

`Monstera.REST.setupMethodFilters('post', function(s){return s}, function(s){return s})`

And if we want to return to the default behaviour later, we could call:

```
Monstera.REST.setupMethodFilters('post', function(s, xhr) {
	xhr.setRequestHeader('Content-Type', 'application/json');
	return JSON.stringify(s)
}, function(s){return JSON.parse(s)})
```

But, for your convenience, if you want to reset all method filters at once, you can call a special method `Monstera.REST.resetMethodFilters()`, and everything will be in its initial state.


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

That's it! Once you run a `save()` or `sync()` method on your `Monstera.Data.Store` instance, the template will be automagically refreshed with your new data on any element matching the `selector`. And if you have event listeners set up with `Monstera.DOM.on`, you will never lose them after template refreshing, nor you'll get any duplicates whatsoever. That's where different framework components perform together very well.

If you need, for whatever reason, just to render a template with parameters into a string (but not bother fetching it and calling the underlying engine directly), you can use `renderText` method:

`Monstera.Templates.renderText(templatePathOrName, params, callback)`

And it will just return rendered HTML into the callback.

Addons
------

Have you seen an empty `src/addons/` directory if you have cloned the repo? It's right for you. You can place any single `*.coffee` file there (in any nested directory structure if you wish) and it will be built into the `output/monstera.js` file as an addon ready to be distributed alongside the core framework. This way you can extend Monstera functionality building on top of its features. Create a pull request when you think your addon is ready for sharing with the world, and all useful addons will be included in this repo.
