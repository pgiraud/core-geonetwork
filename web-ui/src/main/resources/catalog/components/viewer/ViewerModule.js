(function () {
  goog.provide('gn_viewer');

  goog.require('gn');
  goog.require('gn_viewer_directive');
  goog.require('gn_viewer_service');
  goog.require('gn_wmsimport_directive');
  goog.require('gn_layermanager_directive');
  goog.require('gn_measure_directive');
  goog.require('gn_draw_directive');
  goog.require('gn_ows');
  goog.require('gn_popup');
  goog.require('gn_ncwms');

  var module = angular.module('gn_viewer', [
    'gn_ncwms',
    'gn_viewer_service',
    'gn_viewer_directive',
    'gn_wmsimport_directive',
    'gn_layermanager_directive',
    'gn_measure_directive',
    'gn_draw_directive',
    'gn_ows',
    'gn_popup',
    'gn'
  ]);

  module.controller('gnViewerController',
    ['$scope', 'gnNcWms',
      function($scope, gnNcWms) {

        /** Define object to receive measure info */
        $scope.measureObj = {};

        /** Define vector layer used for drawing */
        $scope.drawVector;

        /** print definition */
        $scope.printactive = true;

        var bgLayer = new ol.layer.Tile({
          source: new ol.source.OSM()
        });
        bgLayer.displayInLayerManager = false;
        bgLayer.background = true;

        // TODO : Move on layer load
        $scope.ncwmsLayer = gnNcWms.createNcWmsLayer();
        $scope.ncwmsLayer.displayInLayerManager = true;

        $scope.map = new ol.Map({
          renderer: 'canvas',
          layers: [
/*
            new ol.layer.Tile({
              source: new ol.source.Stamen({
                layer: 'watercolor'
              })
            }),
            new ol.layer.Tile({
              source: new ol.source.Stamen({
                layer: 'terrain-labels'
              })
            }),
*/
            bgLayer
          ],
          target: 'map',
          view: new ol.View({
            center: ol.proj.transform(
              [-1.99667, 49.0], 'EPSG:4326', 'EPSG:3857'),
            zoom: 6
          })
        });
        $scope.map.addLayer($scope.ncwmsLayer);
      }]);

  module.controller('toolsController',
      ['$scope', 'gnMeasure',
        function($scope, gnMeasure) {
          $scope.mInteraction = gnMeasure.create($scope.map, $scope.measureObj, $scope);
          $scope.activeTools = {};
        }
      ]);

})();