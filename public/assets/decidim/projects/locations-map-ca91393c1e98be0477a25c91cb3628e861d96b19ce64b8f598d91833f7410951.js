/**
 * Map Location
 */


var osmUrl = "https://osm.cdsh.dev/hot/{z}/{x}/{y}.png";
var nominatimUrl = "https://nominatim.cdsh.dev";

var loadingAddressText = "Wczytywanie adresu...";

var locations = {};
var markers = {};

// set map
var map = L.map("map", {
  minZoom: 10,
  maxZoom: 17,
  gestureHandling: true
}).setView([52.22977, 21.01178], 11);

$('#map').removeAttr('tabIndex');

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

map.on("click", addMarker);

var project_locations = JSON.parse($('input[name="project[locations_json]"]').val());

if (!$.isEmptyObject(project_locations)) {
  var bounds = [];
  $.each(project_locations, function(k, v) {
    addMarker({
      latlng: {
        lat: v.lat,
        lng: v.lng
      },
      display_name: v.display_name,
      address: v.address
    }, k);
    bounds.push([v.lat, v.lng]);
  });

  map.fitBounds(bounds, { animate: false });
}

//var inputNewLocation = $('#location-input-new'); // zmienic na search
//inputNewLocation.on('keypress', function (e) {
//  var keycode = (e.keyCode ? e.keyCode : e.which);
//  if (keycode == '13') addNewLocation();
//});

// add marker
function addMarker(e, id = Date.now()) {
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

  if (e.latlng.lat < restrictArea.lat.from || e.latlng.lat > restrictArea.lat.to || e.latlng.lng < restrictArea.lng.from || e.latlng.lng > restrictArea.lng.to) {
    
    $('.out-of-bounds-modal-js').closest('.reveal-overlay').show();
    $('.out-of-bounds-modal-js').show();

    return false; 
  };
  

  locations[id] = {
    lat: e.latlng.lat,
    lng: e.latlng.lng,
    display_name: e.display_name || null,
    address: e.address || null,
  };

  var addressText = e.display_name || loadingAddressText;

  markers[id] = new L.marker(e.latlng, {
    icon: new LeafIcon({ iconUrl: icon_file('blue') }),
    draggable: true
  })
    .addTo(map)
    .bindPopup(addressText);

  // $('.locations').append(`<p>
  $('.locations-list').append(`<div class="locations-list__item">
    <input type="text" readonly id="input-location-${id}" value="${addressText}" class="added-marker" /> 
    <input type="button" id="location-delete-${id}" value="usuń" class="button small change" />
  </div>`);

  $(`#location-delete-${id}`).click(() => {
    removeLocation(id);
  });

  geocodeLatLng(id, e.address == null);
  markerEvents(id);

  serializeLocations();
}

// set marker events
function markerEvents(id) {
  // click
  markers[id].on('click', function (e) {
    var popup = e.target.getPopup();
    popup.setContent(locations[id].display_name);
  });
  
  // drag
  markers[id].on("dragend", function (e) {
    locations[id].lat = e.target.getLatLng().lat;
    locations[id].lng = e.target.getLatLng().lng
  
    geocodeLatLng(id);
  });
}

// gecode LatLng
function geocodeLatLng(id, geocode = true) {
  if (geocode) {
    $.getJSON(`${nominatimUrl}/reverse?format=json&lat=${locations[id].lat}&lon=${locations[id].lng}&addressdetails=1`, function(json) {
      locations[id].display_name = prepareDisplayName(json);
      locations[id].address = json.address;

      serializeLocations();

      $(`#input-location-${id}`).val(locations[id].display_name);
    });
  }
}

// prepare display name
function prepareDisplayName(obj) {
  return `${obj.address.road || ''} ${obj.address.house_number || ''}, ${obj.address.postcode || ''} ${obj.address.city || ''}`;
}

// change input value
function changeInputValue(id) {
  var input = $(`#input-location-${id}`);
  input.parent().find('input.change').prop('disabled', locations[id].display_name.trim() === input.val().trim());
}

// remove location
function removeLocation(id) {
  map.removeLayer(markers[id]);
  delete markers[id];
  delete locations[id];
  
  $(`#input-location-${id}`).parent().remove();

  serializeLocations();
}

function serializeLocations() {
  // $('input[name="project[locations][]"]').val(JSON.stringify(locations));
  $('input[name="project[locations_json]"]').val(JSON.stringify(locations));
}

// autocomplete
new Autocomplete("search", {
  // default selects the first item in
  // the list of results
  selectFirst: true,

  // The number of characters entered should start searching
  howManyCharacters: 3,

  // onSearch
  onSearch: ({ currentValue }) => {
    // You can also use static files
    // const api = '../static/search.json'
    const api = `${nominatimUrl}/search?format=geojson&limit=5&addressdetails=1&countrycodes=pl&city=Warszawa&street=${encodeURI(
      currentValue
    )}`;

    return new Promise((resolve) => {
      fetch(api)
        .then((response) => response.json())
        .then((data) => {
          resolve(data.features);
        })
        .catch((error) => {
          console.error(error);
        });
    });
  },
  // nominatim GeoJSON format parse this part turns json into the list of
  // records that appears when you type.
  onResults: ({ currentValue, matches, template }) => {
    const regex = new RegExp(currentValue, "gi");

    // if the result returns 0 we
    // show the no results element
    return matches === 0
      ? template
      : matches
          .map((element) => {
            // const display_name = prepareDisplayName(element.properties);
            return `
          <li class="loupe">
            <p>
              ${element.properties.display_name.replace(
                regex,
                (str) => `<b>${str}</b>`
              )}
            </p>
          </li> `;
          })
          .join("");
  },

  // we add an action to enter or click
  onSubmit: ({ object, element }) => {
    // console.log(object);
    // console.log(element);

    const { display_name, address } = object.properties;
    const cord = object.geometry.coordinates;

    // console.log('test');

    // create marker and add to map
    addMarker({
      latlng: {
        lat: cord[1],
        lng: cord[0]
      },
      display_name: display_name,
      address: address
    }, Date.now());

    // sets the view of the map
    map.setView([cord[1], cord[0]]);

    // clear value
    $(element).val('');
  },

  // get index and data from li element after
  // hovering over li with the mouse or using
  // arrow keys ↓ | ↑
  onSelectedItem: ({ index, element, object }) => {
    // console.log("onSelectedItem:", index, element, object);
  },

  // the method presents no results element
  noResults: ({ currentValue, template }) =>
    template(`<li>Brak wyników dla: "${currentValue}"</li>`),
});
