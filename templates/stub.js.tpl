/*
 * This is an underscore template for creating AngularJS provider stubs. It expects a `stubs` array, containing string
 * definitions of stub objects. The result of executing the given expression should be a single object, with the
 * following properties:
 *
 * $module: name of the module to stub
 * $services: a dictionary of service definitions, with the key being the name of the service. Read on for an example.
 *
 * The stub object can be defined in various ways:
 *
 * JSON object
 * { "$module": "moduleName", "$services": { ... } }
 *
 * JavaScript object
 * stub = { $module: 'moduleName', $services: { ... } }
 *
 * JavaScript function, returning the stub object
 * function() { var stub = {}; stub.$module = 'moduleName'; stub.$services = { ... }; return stub; };
 *
 * JavaScript self-executing function, returning the stub object
 * (function() { var stub = {}; stub.$module = 'moduleName'; stub.$services = { ... }; return stub; })();
 *
 * Here is an example of a JavaScript file containing the stub:

   (function() {
      var stub = {};

      var printMyName = function() {
         console.log('This is a PRIVATE helper in stubbed module for module ' + stub.$module);
      };

      stub.$module = "stubTest3";

      stub.$services = {
         "stubTestService": {
            "$functions": {
               "all": [
                  {
                     "$arguments": "*",

                     "$config": {
                        "$delay": 3000
                     },

                     "$returnValue": ["xz", "y", "z"]
                  },
                  {
                     "$arguments": ["a"],

                     "$config": {
                        "$delay": 1000
                     },

                     "$returnValue": function() {
                        printMyName();
                        return ["Just making sure e\'s\"c\'a\"p\'e characters are handled just fine."];
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
                     },

                     "$returnValue": ["y", "z"]
                  }
               ]
            }
         }
      };

      return stub;
   })();

**/

(function() {
   var noBackend = document.URL.match(/[\?&]nobackend/);
   if(noBackend) {
      var createStub = function($stubDefinition) {
         var $q, $timeout;
         var module = angular.module($stubDefinition.$module, []);

         Object.keys($stubDefinition.$services).forEach(function($serviceName) {
            var $serviceDefinition = $stubDefinition.$services[$serviceName];
            var $serviceFunctions = $serviceDefinition.$functions;

            module.provider($serviceName, function() {
               var provider = this;
               var serviceObject = {};

               Object.keys($serviceFunctions).forEach(function($fnName) {
                  var $fnDefinitions = $serviceFunctions[$fnName];

                  serviceObject[$fnName] = function() {
                     var args = Array.prototype.slice.call(arguments, 0);

                     var $matchingFunctions = $fnDefinitions.filter(function($fn) {
                        return JSON.stringify($fn.$arguments) === JSON.stringify(args);
                     });

                     if($matchingFunctions.length === 0) {
                        $matchingFunctions = $fnDefinitions.filter(function($fn) {
                           return $fn.$arguments === "*";
                        });
                     }

                     if($matchingFunctions.length === 0) {
                        console.error("Stub not found: " + $serviceName + "." + $fnName + ", Arguments: ", args);
                        return;
                     }

                     var matchedFunction = $matchingFunctions[0];
                     console.info("Stub found: " + $serviceName + "." + $fnName + ", Arguments: ", args,
                        "Stub: ", matchedFunction);

                     var $config = matchedFunction.$config || {};
                     var $returnValue = matchedFunction.$returnValue || {};

                     var $delay = typeof $config.$delay ===
                                  'number' &&
                                  $config.$delay >=
                                  0 ?
                                  $config.$delay :
                                  undefined;

                     var returnValue;
                     if(typeof $returnValue === "function") {
                        returnValue = $returnValue.apply($stubDefinition, args);
                     } else {
                        returnValue = $returnValue;
                     }

                     if($delay >= 0) {
                        var deferred = $q.defer();
                        var value = returnValue;

                        $timeout(function() {
                           deferred.resolve(value);
                        }, $delay);

                        returnValue = deferred.promise;
                     }

                     return returnValue;
                  }
               });

               provider.$get = function(_$q_, _$timeout_) {
                  $q = _$q_;
                  $timeout = _$timeout_;

                  return serviceObject;
               };
            });
         });
      };

      // <%= '\r\n var __stub = ' + contents %>

      if(typeof __stub === "function") {
         __stub = __stub();
      }

      createStub(__stub);
   }
})();