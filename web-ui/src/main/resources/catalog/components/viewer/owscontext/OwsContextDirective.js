(function () {
  goog.provide('gn_owscontext_directive');

  var module = angular.module('gn_owscontext_directive', []);

  /**
   * @ngdoc directive
   * @name gn_owscontext_directive.directive:gnOwsContext
   *
   * @description
   * Panel to load WMS capabilities service and pick layers.
   * The server list is given in global properties.
   */
  module.directive('gnOwsContext', [
    function () {
      return {
        restrict: 'A',
        templateUrl: '../../catalog/components/viewer/owscontext/' +
          'partials/owscontext.html',
        scope: {
          map: '='
        },
        link: function(scope, element, attrs) {
        }
      };
    }
  ]);
})();
