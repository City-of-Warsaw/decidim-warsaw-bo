"use strict";

(function () {
  var $creatorSelect = $("#import_creator");
  var $creatorGuidances = $(".creator-guidances").find(".guidance");

  var showGuidance = function showGuidance(text) {
    var formatted = text.replace(/\s/g, "").toLocaleLowerCase();
    $.each($creatorGuidances, function (_index, currentValue) {
      if (currentValue.className.includes(formatted)) {
        var elem = $(currentValue);
        elem.show();
      }
    });
  };

  $creatorSelect.on("change", function () {
    var text = $("#import_creator option:selected").text();
    $creatorGuidances.hide();
    if (text) {
      showGuidance(text);
    }
  });

  if ($creatorSelect.children("option").length < 2) {
    $("label[for='import_creator']").hide();
  }
  $creatorGuidances.hide();
  $creatorGuidances.first().show();
})();
