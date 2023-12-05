"use strict";

$(function () {
  var attachGeocoding = window.Decidim.attachGeocoding;

  var $form = $(".project_form_admin");

  if ($form.length > 0) {
    (function () {
      var $projectCreatedInMeeting = $form.find("#project_created_in_meeting");
      var $projectMeeting = $form.find("#project_meeting");

      var toggleDisabledHiddenFields = function toggleDisabledHiddenFields() {
        var enabledMeeting = $projectCreatedInMeeting.prop("checked");
        $projectMeeting.find("select").attr("disabled", "disabled");
        $projectMeeting.hide();

        if (enabledMeeting) {
          $projectMeeting.find("select").attr("disabled", !enabledMeeting);
          $projectMeeting.show();
        }
      };

      $projectCreatedInMeeting.on("change", toggleDisabledHiddenFields);
      toggleDisabledHiddenFields();

      var $projectAddress = $form.find("#project_address");
      if ($projectAddress.length !== 0) {
        attachGeocoding($projectAddress);
      }
    })();
  }
});
