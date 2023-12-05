/**
 * Markers Map
 */


const osmUrl = "https://osm.cdsh.dev/hot/{z}/{x}/{y}.png";

// map
const mapDiv = $('#map');
const paramLegend = mapDiv.data('legend') || false;
const paramLabels = mapDiv.data('labels') || {};

const map = L.map('map', {
  minZoom: 10,
  maxZoom: 15,
  gestureHandling: true
}).setView([52.22977, 21.01178], 10);

mapDiv.removeAttr('tabIndex');

L.tileLayer(osmUrl, {
  attribution:
    '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);

// icons
var iconsTypes = ['blue', 'green', 'gray', 'orange'];

var LeafIcon = L.Icon.extend({
  options: {
    iconSize:     [28, 36],
    iconAnchor:   [14, 36],
    popupAnchor:  [0, -24]
  }
});

//const iconFile = (type) => `${type}-icon.png`;
function icon_file(type) {
  if (type == 'blue') {
    return '/assets/decidim/projects/images/blue-icon-d0cbfec766bba03d84aabb4cc6deb76f4e5b47ee1dafab939d1af67d3b5fdd33.png';
  } else if (type == 'green') {
    return '/assets/decidim/projects/images/green-icon-463265f8907a2778a8740aebfa91660e3b01c0fc817efed3bf65fe1e7dc47cc3.png';
  } else if (type == 'gray') {
    return '/assets/decidim/projects/images/gray-icon-cd802e127f92fd9c260e5d7142bfef0741eb871848e59331d4c08a44a41a387c.png';
  } else if (type == 'orange') {
    return '/assets/decidim/projects/images/orange-icon-d48ae94d8b6d238fa2140e9cc3fbc6762f68e1b53e335a8416dcb0644529673d.png';
  }  else {
    return  '/assets/decidim/projects/images/blue-icon-d0cbfec766bba03d84aabb4cc6deb76f4e5b47ee1dafab939d1af67d3b5fdd33.png';
  }
}


var counter = [];
iconsTypes.forEach(function (v) {
  counter[v] = 0;
});

// clusters
var clusters = L.markerClusterGroup({ chunkedLoading: true, showCoverageOnHover: false, maxClusterRadius: 20 });

var markersOnMap = {};
var total = 0;

$("document").ready(function() {
  // markers
  const markersInput = $('input[name="markersMap"]');        
  const selectedProjectsInput = $('input[class="selected-projects-js"]');
  const highlightedProjectsInput = $('input[class="highlighted-projects-js"]');

  function clickZoom(e) { 
    map.setView([e.target.getLatLng().lat + 0.002, e.target.getLatLng().lng], 15);
    setTimeout(function () {map.invalidateSize(true)}, 100)
  }

  function addMarkers(resetBounds = true) {
    // clear markers
    clusters.clearLayers();
    $(".leaflet-marker-icon").remove();

    const markersJson = markersInput.val();

    if (markersJson.length>0) {
      var bounds = [];
      var markers = JSON.parse(markersJson);
      total = Object.keys(markers).length;

      $.each(markers, function(k, v) {
        var restrictArea = {
          lat: {
            from: 52.098913320836104,
            to: 52.36218321674427
          },
          lng: {
            from: 20.758666992187504,
            to: 21.272277832031254
          }
        };

        if (v.lat < restrictArea.lat.from || v.lat > restrictArea.lat.to || v.lng < restrictArea.lng.from || v.lng > restrictArea.lng.to) return false;
 
        let selectedProjectsArray = selectedProjectsInput.val() ? selectedProjectsInput.val().split(",").map(value => parseInt(value)) : [];
        let highlightedProjectsArray = highlightedProjectsInput.val() ? highlightedProjectsInput.val().split(",").map(value => parseInt(value)) : [];

        counter[v.icon]++;
        markersOnMap[k] = new L.marker(
            { lat: v.lat, lng: v.lng },
            { 
              icon: 
                new LeafIcon({
                  iconUrl: icon_file(selectedProjectsArray.includes(v.pId) ? 'orange' : highlightedProjectsArray.includes(v.pId) ? 'blue' : 'gray') 
                }),
              alt: v.title || '' 
            })
          .addTo(clusters)
          .bindPopup(function() {
            var el = document.createElement('div');

            el.innerHTML ="<div class='loading-spinner'></div>";

            // $.get(`/projects/${v.pId}/map_details_data`).done(function(data) {
            $.get(v.popupUrl).done(function(data) {
              el.innerHTML = data;
            });

            return el;
          }, { 
            'className': `popup-${v.icon}`
          }).on('click', function(e) { 
            $.each(markers, function(itemK, itemV) {
              let selectedProjectsArray = selectedProjectsInput.val() ? selectedProjectsInput.val().split(",").map(value => parseInt(value)) : []; 

              var iconName = selectedProjectsArray.includes(itemV.pId) ? 'orange' : (v.pId && itemV.pId == v.pId) ? 'blue' : 'gray'; 
              markersOnMap[itemK] && markersOnMap[itemK].setIcon(new LeafIcon({ iconUrl: icon_file(iconName) }));

              markersOnMap[itemK] && markersOnMap[itemK].getPopup().on('remove', function() {
                $.each(markers, function(itemK, itemV) {
                  let selectedProjectsArray = selectedProjectsInput.val() ? selectedProjectsInput.val().split(",").map(value => parseInt(value)) : []; 
                  markersOnMap[itemK] && markersOnMap[itemK].setIcon(new LeafIcon({ iconUrl: icon_file(selectedProjectsArray.includes(itemV.pId) ? 'orange' : 'gray') }));
                });
              });
            });

            clickZoom(e);
          });

        bounds.push([v.lat, v.lng]);
      });

      if (bounds.length > 0) {
        map.addLayer(clusters);

        if (resetBounds)
          map.fitBounds(bounds, { animate: false });
      }
    };

    // legend
    if (paramLegend && paramLabels) {
      L.control.Legend({
        title: ` `,
        position: "bottomleft",
        // position: $(window).width() <= 640 ? "bottomleft" : "topright", // Uwzglednienie szerokosci mobile
        legends: iconsTypes.map(function(v) {
          return paramLabels[v].length>0 ? {
            type: 'image',
            url: icon_file(v),
            count: counter[v],
            // label: `${paramLabels[v]} (${counter[v]})`,
            label: `${paramLabels[v]}`
          } : '';
        })
      }).addTo(map);
    }
  }

  addMarkers();

  markersInput.change(() => addMarkers(true));
  
  selectedProjectsInput.change(() => addMarkers(false));
  highlightedProjectsInput.change(() => addMarkers(false));
});
