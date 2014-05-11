# warlock-spell-angular-stubs

This is a [Warlock](https://github.com/ngbp/warlock) spell to generate stub AngularJS provider modules, by processing `*.stub.js` and `*.stub.json` files containing stub definitions. It is pretty much my first stab at it, so it has some rough edges, and perhaps not quite *ready* code. I have therefore decided to mark it as a private repository in `package.json` and not publish to NPM.

The main part of this plugin is actually the stub template, and not the plugin code itself. The plugin code simply reads files from the input stream, and processes them through the default template (overrideable), before merging the results into [warlock-spell-webapp](https://github.com/ngbp/spell-webapp)'s `scripts-to-build` flow.

## Default Template

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

### createStub()

The template takes stub definition objects, and passes them into the `createStub` function, which registers an AngularJS module with the given name, and iterates through `$services`, registering AngularJS providers on that module. It basically overrides the original modules and services by redefining the module, and providing new implementation. Hence, it is important that the generated stubs are loaded into the app after the original ones.

Also, the stubbing only happens if the `noBackend` parameter appears in the URL. If you normally run your app at `file://path/to/app/index.html`, for the stubs to kick in, you'd have to go to `file://path/to/app/index.html?noBackend`.

## Example

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
                  "$arguments": "*",   // matches any set of arguments

                  "$config": {
                     "$delay": 3000    // Setting the delay causes the function to return a promise
                  },

                  "$returnValue": ["x", "y", "z"]
               },
               {
                  "$arguments": ["a"], // match a particular set of arguments

                  "$config": {
                     "$delay": 1000    // resolve promise after 1 second
                  },

                  // return value can be a function, the return value of which will be returned to the caller
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

                  "$config": {
                     // I have no delay. I return the return value as a plain object/value immediately
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

## To Do:

- Make it possible to let the stub reject a promise instead of resolving
- Make it possible for stubs to take in callback functions and execute the callback, optionally with a delay
- Make it possible to define constants, values, and provider methods.
- More...