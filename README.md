# `warlock-spell-angular-stubs`

This is a [Warlock](https://github.com/ngbp/warlock) spell to generate stub AngularJS provider modules, by processing `*.stub.js` and `*.stub.json` files containing stub definitions. It is pretty much my first stab at it, so it has some rough edges, and perhaps not quite *ready* code. I have therefore decided to mark it as a private repository in `package.json` and not publish to NPM.

The main part of this plugin is actually the stub template, and not the plugin code itself. The plugin code simply reads files from the input stream, and processes them through the default template (overrideable), before merging the results into [warlock-spell-webapp](https://github.com/ngbp/spell-webapp)'s `scripts-to-build` flow.

The default template expects stub definitions (content of stub source files) to be in either one of these formats:

### JSON Object (`.json`)
```json
{ "$module": "moduleName", "$services": { ... } }
```

### Javascript variable (`.js`)
```js
stub = { $module: 'moduleName', $services: { ... } }
```

### Javascript function object (`.js`)
```js
stub = function() { this.$module = 'moduleName'; this.$services = { ... }; return this; };
```

### Javascript self-executing function (`.js`)
```js
(function() { this.$module = 'moduleName'; this.$services = { ... }; return this; })();
```

Here is what the properties mean:

- `$module`: name of the module to stub
- `$services`: a dictionary of service definitions, with the key being the name of the service.

And here is a full example, showing what's possible:

```js
(function() {
   var stub = {};

   var printMyName = function() {
      console.log('This is a PRIVATE helper in stubbed module for module ' + stub.$module);
   };

   stub.$module = "stubExample";

   stub.$services = {
      "stubExampleService": {
         "$functions": {
            "all": [
               {
                  "$arguments": "*",	// matches any set of arguments

                  "$config": {
                     "$delay": 3000		// Setting the delay causes the function to return a promise
                  },

                  "$returnValue": ["x", "y", "z"]
               },
               {
                  "$arguments": ["a"],	// match a particular set of arguments

                  "$config": {
                     "$delay": 1000		// resolve promise after 1 second
                  },

                  "$returnValue": function() {
                     printMyName();
                     return ["I logged and returned."];
                  }
               }
            ],
            "one": [
               {
                  "$arguments": "*",

                  "$config": {
                     "$delay": 2000
                  },

                  "$returnValue": ["x"]
               }
            ],
            "two": [
               {
                  "$arguments": "*",

                  "$config": {			// I have no delay. I return the return immediately without a promise
                  },

                  "$returnValue": ["y", "z"]
               }
            ]
         }
      }
   };

   return stub;
})();
```