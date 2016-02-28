var MonsteraLib;

MonsteraLib = {};

(function(e) {
  var closest;
  e.matches = e.matches || e.webkitMatchesSelector || e.mozMatchesSelector || e.msMatchesSelector || e.oMatchesSelector || function(sel) {
    var elem, i, len, ref;
    ref = (this.document || this.ownerDocument).querySelectorAll(sel);
    for (i = 0, len = ref.length; i < len; i++) {
      elem = ref[i];
      if (elem === this) {
        return true;
      }
    }
    return false;
  };
  return e.closest = e.closest || (closest = function(sel) {
    if (this.parentNode) {
      if (this.matches(sel)) {
        return this;
      } else {
        return closest.call(this.parentNode, sel);
      }
    } else {
      return null;
    }
  });
})(Element.prototype);

(function() {
  var dom, evcache, genEventKey;
  evcache = {};
  genEventKey = function(selector, evtype) {
    return selector + '#' + evtype;
  };
  dom = {
    ready: function(cb) {
      var ref;
      if ((ref = document.readyState) === 'interactive' || ref === 'complete') {
        return cb();
      } else {
        return window.addEventListener('DOMContentLoaded', cb, false);
      }
    },
    load: function(cb) {
      if (document.readyState === 'complete') {
        return cb();
      } else {
        return window.addEventListener('load', cb, false);
      }
    },
    on: function(selector, evtype, cb) {
      var evkey, evname, i, len, ref, results;
      ref = evtype.split(' ');
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        evname = ref[i];
        evkey = genEventKey(selector, evname);
        evcache[evkey] = function(e) {
          var targetElem;
          if (targetElem = e.target.closest(selector)) {
            return cb(e, targetElem);
          }
        };
        results.push(window.addEventListener(evname, evcache[evkey], false));
      }
      return results;
    },
    off: function(selector, evtype) {
      var evkey, evname, i, len, ref, results;
      ref = evtype.split(' ');
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        evname = ref[i];
        evkey = genEventKey(selector, evname);
        if (evcache[evkey] != null) {
          window.removeEventListener(evname, evcache[evkey]);
          results.push(delete evcache[evkey]);
        } else {
          results.push(void 0);
        }
      }
      return results;
    },
    qS: function(s) {
      return document.querySelector(s);
    },
    qSA: function(s) {
      return document.querySelectorAll(s);
    },
    prevent: function(e) {
      e.preventDefault();
      return e.stopPropagation();
    },
    setupDropzone: function(selector, cb) {
      var elem;
      elem = dom.qS(selector);
      elem.addEventListener('dragover', function(e) {
        dom.prevent(e);
        return e.dataTransfer.effect = 'copy';
      }, false);
      return elem.addEventListener('drop', function(e) {
        dom.prevent(e);
        return cb(e);
      }, false);
    }
  };
  return MonsteraLib.DOM = dom;
})();

(function() {
  var internalAjaxCall, methodFilters, resetMethodFilters, rest, setupMethodFilters;
  methodFilters = {};
  (resetMethodFilters = function() {
    return methodFilters = {
      get: {
        request: function(s) {
          return s;
        },
        response: function(s) {
          return JSON.parse(s);
        }
      },
      post: {
        request: function(s, xhr) {
          xhr.setRequestHeader('Content-Type', 'application/json');
          return JSON.stringify(s);
        },
        response: function(s) {
          return JSON.parse(s);
        }
      },
      put: {
        request: function(s, xhr) {
          xhr.setRequestHeader('Content-Type', 'application/json');
          return JSON.stringify(s);
        },
        response: function(s) {
          return JSON.parse(s);
        }
      },
      'delete': {
        request: function(s) {
          return s;
        },
        response: function(s) {
          return JSON.parse(s);
        }
      }
    };
  })();
  internalAjaxCall = function(url, method, rawData, cb, errCb) {
    var lMethod, realRequest, xhr;
    if (errCb == null) {
      errCb = null;
    }
    lMethod = method.toLowerCase();
    xhr = new XMLHttpRequest;
    xhr.open(method, url, true);
    xhr.onload = function() {
      var realResponse;
      realResponse = null;
      try {
        realResponse = methodFilters[lMethod].response(xhr.responseText);
      } catch (undefined) {}
      if (xhr.status === 200) {
        return cb(realResponse);
      } else if (errCb != null) {
        return errCb(realResponse, xhr.status);
      }
    };
    realRequest = rawData;
    try {
      realRequest = methodFilters[lMethod].request(rawData, xhr);
    } catch (undefined) {}
    return xhr.send(realRequest);
  };
  setupMethodFilters = function(method, requestFilter, responseFilter) {
    method = method.toLowerCase();
    if (methodFilters[method] != null) {
      methodFilters[method].request = requestFilter;
      methodFilters[method].response = responseFilter;
    }
    return true;
  };
  rest = {
    get: function(url, cb, errCb) {
      if (errCb == null) {
        errCb = null;
      }
      return internalAjaxCall(url, 'GET', null, cb, errCb);
    },
    post: function(url, obj, cb, errCb) {
      if (errCb == null) {
        errCb = null;
      }
      return internalAjaxCall(url, 'POST', obj, cb, errCb);
    },
    put: function(url, obj, cb, errCb) {
      if (errCb == null) {
        errCb = null;
      }
      return internalAjaxCall(url, 'PUT', obj, cb, errCb);
    },
    'delete': function(url, cb, errCb) {
      if (errCb == null) {
        errCb = null;
      }
      return internalAjaxCall(url, 'DELETE', null, cb, errCb);
    },
    setupMethodFilters: setupMethodFilters,
    resetMethodFilters: resetMethodFilters
  };
  return MonsteraLib.REST = rest;
})();

(function() {
  var getRoutePath, routeCache, routes;
  routeCache = {};
  getRoutePath = function() {
    return window.location.pathname + window.location.search + window.location.hash;
  };
  routes = {
    go: function(path, preventHistoryUpdates) {
      var cacheObj, formalPath, i, len, matchList, param, params, ref;
      if (preventHistoryUpdates == null) {
        preventHistoryUpdates = false;
      }
      for (formalPath in routeCache) {
        cacheObj = routeCache[formalPath];
        if (matchList = path.match(cacheObj.regex)) {
          matchList.shift();
          params = {};
          ref = cacheObj.params;
          for (i = 0, len = ref.length; i < len; i++) {
            param = ref[i];
            params[param] = matchList.shift();
          }
          if (!preventHistoryUpdates) {
            window.history.pushState({}, '', path);
          }
          return cacheObj.handler(params);
        }
      }
    },
    add: function(path, cb) {
      var cacheObj, i, len, paramMatches, rawParam, regexString;
      cacheObj = {
        params: [],
        handler: cb
      };
      regexString = path.replace(/\//g, '\\/');
      paramMatches = path.match(/:([^\/]+)/ig);
      for (i = 0, len = paramMatches.length; i < len; i++) {
        rawParam = paramMatches[i];
        cacheObj.params.push(rawParam.substr(1));
        regexString = regexString.replace(rawParam, '([^/]+)');
      }
      cacheObj.regex = new RegExp(regexString, 'i');
      return routeCache[path] = cacheObj;
    },
    remove: function(path) {
      return delete routeCache[path];
    }
  };
  window.addEventListener('popstate', function(e) {
    return routes.go(getRoutePath(), true);
  }, false);
  MonsteraLib.DOM.ready(function() {
    return routes.go(getRoutePath(), true);
  });
  return MonsteraLib.Routes = routes;
})();

var MonsteraStore, MonsteraStoreAdapter,
  hasProp = {}.hasOwnProperty;

MonsteraStoreAdapter = (function() {
  function MonsteraStoreAdapter(setter, getter, remover) {
    this.set = setter;
    this.get = getter;
    this.remove = remover;
  }

  return MonsteraStoreAdapter;

})();

MonsteraStore = (function() {
  function MonsteraStore(key, adapter) {
    if (adapter == null) {
      adapter = MonsteraLib.Data.LocalStorageAdapter;
    }
    Object.defineProperty(this, 'key', {
      configurable: true,
      writable: true,
      value: key
    });
    Object.defineProperty(this, 'adapter', {
      configurable: true,
      writable: true,
      value: adapter
    });
    Object.defineProperty(this, 'internalObject', {
      configurable: true,
      writable: true,
      value: {}
    });
    Object.defineProperty(this, 'subscriptions', {
      configurable: true,
      writable: true,
      value: {}
    });
    this.sync();
  }

  MonsteraStore.prototype.sync = function() {
    var cb, prop, ref, ref1, subId, val;
    this.internalObject = this.adapter.get(this.key);
    if (!this.internalObject) {
      this.internalObject = {};
    }
    ref = this.internalObject;
    for (prop in ref) {
      if (!hasProp.call(ref, prop)) continue;
      val = ref[prop];
      this[prop] = val;
    }
    ref1 = this.subscriptions;
    for (subId in ref1) {
      if (!hasProp.call(ref1, subId)) continue;
      cb = ref1[subId];
      cb.call(this);
    }
    return true;
  };

  MonsteraStore.prototype.save = function() {
    var cb, prop, ref, subId, val;
    this.internalObject = {};
    for (prop in this) {
      if (!hasProp.call(this, prop)) continue;
      val = this[prop];
      this.internalObject[prop] = val;
    }
    this.adapter.set(this.key, this.internalObject);
    ref = this.subscriptions;
    for (subId in ref) {
      if (!hasProp.call(ref, subId)) continue;
      cb = ref[subId];
      cb.call(this);
    }
    return true;
  };

  MonsteraStore.prototype.subscribe = function(cb) {
    var subId;
    while (true) {
      subId = "monstera-sub-" + (Math.random() * 10000 | 0);
      if (this.subscriptions[subId] == null) {
        break;
      }
    }
    this.subscriptions[subId] = cb;
    return subId;
  };

  MonsteraStore.prototype.unsubscribe = function(subId) {
    if (this.subscriptions[subId] != null) {
      return delete this.subscriptions[subId];
    }
  };

  MonsteraStore.prototype.destroy = function() {
    var prop, val;
    this.adapter.remove(this.key);
    this.adapter = null;
    this.key = null;
    this.internalObject = null;
    this.subscriptions = null;
    delete this.subscriptions;
    delete this.key;
    delete this.internalObject;
    delete this.adapter;
    for (prop in this) {
      if (!hasProp.call(this, prop)) continue;
      val = this[prop];
      delete this[prop];
    }
    return delete this;
  };

  return MonsteraStore;

})();

MonsteraLib.Data = {
  Store: MonsteraStore,
  Adapter: MonsteraStoreAdapter
};

MonsteraLib.Data.LocalStorageAdapter = new MonsteraLib.Data.Adapter((function(key, value) {
  try {
    return window.localStorage.setItem("monstera." + key, JSON.stringify(value));
  } catch (undefined) {}
}), (function(key) {
  try {
    return JSON.parse(window.localStorage.getItem("monstera." + key));
  } catch (undefined) {}
}), (function(key) {
  try {
    return window.localStorage.removeItem("monstera." + key);
  } catch (undefined) {}
}));

(function() {
  var fetcher, renderer, subscriptionCache, templates;
  renderer = function(tplContent, params) {
    return tplContent;
  };
  fetcher = function(tplPath, cb) {
    var voidf;
    voidf = function(s) {
      return s;
    };
    MonsteraLib.REST.setupMethodFilters('get', voidf, voidf);
    return MonsteraLib.REST.get(tplPath, function(tplContent) {
      MonsteraLib.REST.resetMethodFilters;
      return cb(tplContent);
    });
  };
  subscriptionCache = {};
  templates = {
    setupRenderer: function(cb) {
      return renderer = cb;
    },
    setupFetcher: function(cb) {
      return fetcher = cb;
    },
    renderText: function(tplPath, params, cb) {
      return fetcher(tplPath, function(tplContent) {
        return cb(renderer(tplContent, params));
      });
    },
    render: function(domSelector, tplPath, store) {
      var actualRenderer, tSubId;
      (actualRenderer = function(sel, tpl, params) {
        return MonsteraLib.DOM.ready(function() {
          var elems;
          if (elems = MonsteraLib.DOM.qSA(sel)) {
            return fetcher(tplPath, function(tplContent) {
              var elem, i, len, outputHtml, results;
              outputHtml = renderer(tplContent, params);
              results = [];
              for (i = 0, len = elems.length; i < len; i++) {
                elem = elems[i];
                results.push(elem.innerHTML = outputHtml);
              }
              return results;
            });
          }
        });
      })(domSelector, tplPath, store);
      tSubId = tplPath + "##" + store.key;
      if (subscriptionCache[tSubId] == null) {
        return subscriptionCache[tSubId] = store.subscribe(function() {
          return actualRenderer(domSelector, tplPath, this);
        });
      }
    }
  };
  return MonsteraLib.Templates = templates;
})();

window.Monstera = MonsteraLib;
