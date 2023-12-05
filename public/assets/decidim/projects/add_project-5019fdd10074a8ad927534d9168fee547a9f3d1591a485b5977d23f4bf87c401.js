"use strict";

$(function () {
  var attachGeocoding = window.Decidim.attachGeocoding;

  window.DecidimProjects = window.DecidimProjects || {};

  window.DecidimProjects.bindProjectAddress = function () {
    var $checkbox = $("input:checkbox[name$='[has_address]']");
    var $addressInput = $("#address_input");
    var $addressInputField = $("input", $addressInput);

    if ($checkbox.length > 0) {
      var toggleInput = function toggleInput() {
        if ($checkbox[0].checked) {
          $addressInput.show();
          $addressInputField.prop("disabled", false);
        } else {
          $addressInput.hide();
          $addressInputField.prop("disabled", true);
        }
      };
      toggleInput();
      $checkbox.on("change", toggleInput);
    }

    if ($addressInput.length > 0) {
      attachGeocoding($addressInputField);
    }
  };

  window.DecidimProjects.bindProjectAddress();
});
