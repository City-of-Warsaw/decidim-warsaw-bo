"use strict";

(function (exports) {
  var $ = exports.$; // eslint-disable-line
  var attachGeocoding = exports.Decidim.attachGeocoding;

  $(function () {
    // Adds the latitude/longitude inputs after the geocoding is done
    attachGeocoding($("#meeting_address"));

    var $form = $(".meetings_form");
    if ($form.length > 0) {
      (function () {
        var $meetingTypeOfMeeting = $form.find("#meeting_type_of_meeting");
        var $meetingOnlineFields = $form.find(".field[data-meeting-type='online']");
        var $meetingInPersonFields = $form.find(".field[data-meeting-type='in_person']");

        var toggleDependsOnSelect = function toggleDependsOnSelect($target, $showDiv, type) {
          var value = $target.val();
          if (value === "hybrid") {
            $showDiv.show();
          } else {
            $showDiv.hide();
            if (value === type) {
              $showDiv.show();
            }
          }
        };

        $meetingTypeOfMeeting.on("change", function (ev) {
          var $target = $(ev.target);
          toggleDependsOnSelect($target, $meetingOnlineFields, "online");
          toggleDependsOnSelect($target, $meetingInPersonFields, "in_person");
        });

        toggleDependsOnSelect($meetingTypeOfMeeting, $meetingOnlineFields, "online");
        toggleDependsOnSelect($meetingTypeOfMeeting, $meetingInPersonFields, "in_person");

        var $meetingRegistrationType = $form.find("#meeting_registration_type");
        var $meetingRegistrationTerms = $form.find("#meeting_registration_terms");
        var $meetingRegistrationUrl = $form.find("#meeting_registration_url");
        var $meetingAvailableSlots = $form.find("#meeting_available_slots");

        $meetingRegistrationType.on("change", function (ev) {
          var $target = $(ev.target);
          toggleDependsOnSelect($target, $meetingAvailableSlots, "on_this_platform");
          toggleDependsOnSelect($target, $meetingRegistrationTerms, "on_this_platform");
          toggleDependsOnSelect($target, $meetingRegistrationUrl, "on_different_platform");
        });

        toggleDependsOnSelect($meetingRegistrationType, $meetingAvailableSlots, "on_this_platform");
        toggleDependsOnSelect($meetingRegistrationType, $meetingRegistrationTerms, "on_this_platform");
        toggleDependsOnSelect($meetingRegistrationType, $meetingRegistrationUrl, "on_different_platform");
      })();
    }
  });
})(window);
