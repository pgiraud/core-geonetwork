(function () {
  goog.provide('gn_owscontext_directive');

  var module = angular.module('gn_owscontext_directive', []);

  // OWC Client
  // Jsonix wrapper to read or write OWS Context
  var context =  new Jsonix.Context(
    [XLink_1_0, OWS_1_0_0, Filter_1_0_0, GML_2_1_2, SLD_1_0_0, OWC_0_3_1],
    {
      namespacePrefixes : {
        "http://www.w3.org/1999/xlink": "xlink"
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
          "localPart": "BoundingBox",
          "prefix": "ows"
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

/*\
|*|
|*|  Base64 / binary data / UTF-8 strings utilities
|*|
|*|  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Base64_encoding_and_decoding
|*|
\*/

/* Array of bytes to base64 string decoding */

function b64ToUint6 (nChr) {

  return nChr > 64 && nChr < 91 ?
      nChr - 65
    : nChr > 96 && nChr < 123 ?
      nChr - 71
    : nChr > 47 && nChr < 58 ?
      nChr + 4
    : nChr === 43 ?
      62
    : nChr === 47 ?
      63
    :
      0;

}

function base64DecToArr (sBase64, nBlocksSize) {

  var
    sB64Enc = sBase64.replace(/[^A-Za-z0-9\+\/]/g, ""), nInLen = sB64Enc.length,
    nOutLen = nBlocksSize ? Math.ceil((nInLen * 3 + 1 >> 2) / nBlocksSize) * nBlocksSize : nInLen * 3 + 1 >> 2, taBytes = new Uint8Array(nOutLen);

  for (var nMod3, nMod4, nUint24 = 0, nOutIdx = 0, nInIdx = 0; nInIdx < nInLen; nInIdx++) {
    nMod4 = nInIdx & 3;
    nUint24 |= b64ToUint6(sB64Enc.charCodeAt(nInIdx)) << 18 - 6 * nMod4;
    if (nMod4 === 3 || nInLen - nInIdx === 1) {
      for (nMod3 = 0; nMod3 < 3 && nOutIdx < nOutLen; nMod3++, nOutIdx++) {
        taBytes[nOutIdx] = nUint24 >>> (16 >>> nMod3 & 24) & 255;
      }
      nUint24 = 0;

    }
  }

  return taBytes;
}

/* Base64 string to array encoding */

function uint6ToB64 (nUint6) {

  return nUint6 < 26 ?
      nUint6 + 65
    : nUint6 < 52 ?
      nUint6 + 71
    : nUint6 < 62 ?
      nUint6 - 4
    : nUint6 === 62 ?
      43
    : nUint6 === 63 ?
      47
    :
      65;

}

function base64EncArr (aBytes) {

  var nMod3 = 2, sB64Enc = "";

  for (var nLen = aBytes.length, nUint24 = 0, nIdx = 0; nIdx < nLen; nIdx++) {
    nMod3 = nIdx % 3;
    if (nIdx > 0 && (nIdx * 4 / 3) % 76 === 0) { sB64Enc += "\r\n"; }
    nUint24 |= aBytes[nIdx] << (16 >>> nMod3 & 24);
    if (nMod3 === 2 || aBytes.length - nIdx === 1) {
      sB64Enc += String.fromCharCode(uint6ToB64(nUint24 >>> 18 & 63), uint6ToB64(nUint24 >>> 12 & 63), uint6ToB64(nUint24 >>> 6 & 63), uint6ToB64(nUint24 & 63));
      nUint24 = 0;
    }
  }

  return sB64Enc.substr(0, sB64Enc.length - 2 + nMod3) + (nMod3 === 2 ? '' : nMod3 === 1 ? '=' : '==');

}

/* UTF-8 array to DOMString and vice versa */

function UTF8ArrToStr (aBytes) {

  var sView = "";

  for (var nPart, nLen = aBytes.length, nIdx = 0; nIdx < nLen; nIdx++) {
    nPart = aBytes[nIdx];
    sView += String.fromCharCode(
      nPart > 251 && nPart < 254 && nIdx + 5 < nLen ? /* six bytes */
        /* (nPart - 252 << 32) is not possible in ECMAScript! So...: */
        (nPart - 252) * 1073741824 + (aBytes[++nIdx] - 128 << 24) + (aBytes[++nIdx] - 128 << 18) + (aBytes[++nIdx] - 128 << 12) + (aBytes[++nIdx] - 128 << 6) + aBytes[++nIdx] - 128
      : nPart > 247 && nPart < 252 && nIdx + 4 < nLen ? /* five bytes */
        (nPart - 248 << 24) + (aBytes[++nIdx] - 128 << 18) + (aBytes[++nIdx] - 128 << 12) + (aBytes[++nIdx] - 128 << 6) + aBytes[++nIdx] - 128
      : nPart > 239 && nPart < 248 && nIdx + 3 < nLen ? /* four bytes */
        (nPart - 240 << 18) + (aBytes[++nIdx] - 128 << 12) + (aBytes[++nIdx] - 128 << 6) + aBytes[++nIdx] - 128
      : nPart > 223 && nPart < 240 && nIdx + 2 < nLen ? /* three bytes */
        (nPart - 224 << 12) + (aBytes[++nIdx] - 128 << 6) + aBytes[++nIdx] - 128
      : nPart > 191 && nPart < 224 && nIdx + 1 < nLen ? /* two bytes */
        (nPart - 192 << 6) + aBytes[++nIdx] - 128
      : /* nPart < 127 ? */ /* one byte */
        nPart
    );
  }

  return sView;

}

function strToUTF8Arr (sDOMStr) {

  var aBytes, nChr, nStrLen = sDOMStr.length, nArrLen = 0;

  /* mapping... */

  for (var nMapIdx = 0; nMapIdx < nStrLen; nMapIdx++) {
    nChr = sDOMStr.charCodeAt(nMapIdx);
    nArrLen += nChr < 0x80 ? 1 : nChr < 0x800 ? 2 : nChr < 0x10000 ? 3 : nChr < 0x200000 ? 4 : nChr < 0x4000000 ? 5 : 6;
  }

  aBytes = new Uint8Array(nArrLen);

  /* transcription... */

  for (var nIdx = 0, nChrIdx = 0; nIdx < nArrLen; nChrIdx++) {
    nChr = sDOMStr.charCodeAt(nChrIdx);
    if (nChr < 128) {
      /* one byte */
      aBytes[nIdx++] = nChr;
    } else if (nChr < 0x800) {
      /* two bytes */
      aBytes[nIdx++] = 192 + (nChr >>> 6);
      aBytes[nIdx++] = 128 + (nChr & 63);
    } else if (nChr < 0x10000) {
      /* three bytes */
      aBytes[nIdx++] = 224 + (nChr >>> 12);
      aBytes[nIdx++] = 128 + (nChr >>> 6 & 63);
      aBytes[nIdx++] = 128 + (nChr & 63);
    } else if (nChr < 0x200000) {
      /* four bytes */
      aBytes[nIdx++] = 240 + (nChr >>> 18);
      aBytes[nIdx++] = 128 + (nChr >>> 12 & 63);
      aBytes[nIdx++] = 128 + (nChr >>> 6 & 63);
      aBytes[nIdx++] = 128 + (nChr & 63);
    } else if (nChr < 0x4000000) {
      /* five bytes */
      aBytes[nIdx++] = 248 + (nChr >>> 24);
      aBytes[nIdx++] = 128 + (nChr >>> 18 & 63);
      aBytes[nIdx++] = 128 + (nChr >>> 12 & 63);
      aBytes[nIdx++] = 128 + (nChr >>> 6 & 63);
      aBytes[nIdx++] = 128 + (nChr & 63);
    } else /* if (nChr <= 0x7fffffff) */ {
      /* six bytes */
      aBytes[nIdx++] = 252 + (nChr >>> 30);
      aBytes[nIdx++] = 128 + (nChr >>> 24 & 63);
      aBytes[nIdx++] = 128 + (nChr >>> 18 & 63);
      aBytes[nIdx++] = 128 + (nChr >>> 12 & 63);
      aBytes[nIdx++] = 128 + (nChr >>> 6 & 63);
      aBytes[nIdx++] = 128 + (nChr & 63);
    }
  }

  return aBytes;

}
