(function () {
  goog.provide('gn_owscontext_directive');

  var module = angular.module('gn_owscontext_directive', []);

  var bgLayers;

  // OWC Client
  // Jsonix wrapper to read or write OWS Context
  var context =  new Jsonix.Context(
    [XLink_1_0, OWS_1_0_0, Filter_1_0_0, GML_2_1_2, SLD_1_0_0, OWC_0_3_1],
    {
      namespacePrefixes : {
        "http://www.w3.org/1999/xlink": "xlink",
        "http://www.opengis.net/ows": "ows"
      }
    }
  );
  var unmarshaller = context.createUnmarshaller();
  var marshaller = context.createMarshaller();

  function loadContext(context, map) {
    // first remove any existing layer
    map.getLayers().forEach(function(layer) {
        console.info('Layer removed: ', layer);
        map.removeLayer(layer);
    });

    // set the General.BoundingBox
    var bbox = context.general.boundingBox.value;
    var ll = bbox.lowerCorner;
    var ur = bbox.upperCorner;
    var extent = ll.concat(ur);
    var projection = bbox.crs;
    // reproject in case bbox's projection doesn't match map's projection
    extent = ol.proj.transformExtent(extent, map.getView().getProjection(), projection);
    map.getView().fitExtent(extent, map.getSize());

    // load the resources
    var layers = context.resourceList.layer;
    var i;
    for (i = 0; i < layers.length; i++) {
        var layer = layers[i];
        if (layer.name.indexOf('google') != -1) {
            // pass
        } else if (layer.name.indexOf('osm') != -1) {
            var osmSource = new ol.source.OSM();
            olLayer = new ol.layer.Tile({source: osmSource});
        } else {
            var server = layer.server[0];
            if (server.service == 'urn:ogc:serviceType:WMS') {
                var onlineResource = server.onlineResource[0];
                var source = new ol.source.ImageWMS({
                    url: onlineResource.href,
                    params: {'LAYERS': layer.name}
                });
                olLayer = new ol.layer.Image({ source: source });
            }
        }
        if (olLayer) {
            olLayer.setOpacity(layer.opacity);
            olLayer.setVisible(!layer.hidden);
            olLayer.set('group', layer.group);
            map.addLayer(olLayer);
        }
    }
}

  // creates a javascript object based on map context then marshals it into XML
  function writeContext(map) {

    var extent = map.getView().calculateExtent(map.getSize());

    var general = {
      boundingBox: {
        name: {
          "namespaceURI": "http://www.opengis.net/ows",
          "localPart": "BoundingBox"
        },
        value: {
          crs: map.getView().getProjection().getCode(),
          lowerCorner: [extent[0], extent[1]],
          upperCorner: [extent[2], extent[3]]
        }
      }
    };

    var resourceList = {
      layer: []
    };
    map.getLayers().forEach(function(layer) {
      var source = layer.getSource();
      var url = "";
      var name;
      if (source instanceof ol.source.OSM) {
        name = "{type=osm}";
      } else if (source instanceof ol.source.ImageWMS) {
        name = source.getParams().LAYERS;
        url = layer.getSource().getUrl();
      }
      resourceList.layer.push({
        hidden: layer.getVisible(),
        opacity: layer.getOpacity(),
        name: name,
        title: layer.get('title'),
        group: layer.get("group"),
        server: [{
          onlineResource: [{
            href: url
          }],
          service: "urn:ogc:serviceType:WMS"
        }]
      });
    });

    var context = {
      version: "0.3.1",
      id: "ows-context-ex-1-v3",
      general: general,
      resourceList: resourceList
    };

    var xml = marshaller.marshalDocument({
      name: {
        localPart: 'OWSContext',
        namespaceURI: "http://www.opengis.net/ows-context",
        prefix: "ows-context",
        string: "{http://www.opengis.net/ows-context}ows-context:OWSContext"
      },
      value: context
    });
    return xml;
  }

  function readAsText(f, callback) {
    try {
      var reader = new FileReader();
      reader.readAsText(f);
      reader.onload = function(e) {
        if (e.target && e.target.result) {
          callback(e.target.result);
        } else {
          console.error("File could not be loaded");
        }
      };
      reader.onerror = function(e) {
        console.error("File could not be read");
      };
    } catch (e) {
      console.error("File could not be read");
    }
  }

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
          scope.save = function($event) {
            var xml = writeContext(scope.map);

            var str = new XMLSerializer().serializeToString(xml);
            var base64 = base64EncArr(strToUTF8Arr(str));
            $($event.target).attr('href', 'data:xml;base64,' + base64);
          };

          var fileInput = element.find('input[type="file"]')[0];
          element.find('.import').click(function() {
            fileInput.click();
          });

          scope.importOwc = function() {
            if (fileInput.files.length > 0) {
              readAsText(fileInput.files[0], function(text) {
                var context = unmarshaller.unmarshalString(text).value;
                loadContext(context, scope.map);
              });
            }
          };
        }
      };
    }
  ]);
})();
