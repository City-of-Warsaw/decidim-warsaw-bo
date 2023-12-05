"use strict";

(function (exports) {
  var _exports$DecidimAdmin = exports.DecidimAdmin;
  var AutoLabelByPositionComponent = _exports$DecidimAdmin.AutoLabelByPositionComponent;
  var AutoButtonsByPositionComponent = _exports$DecidimAdmin.AutoButtonsByPositionComponent;
  var createDynamicFields = _exports$DecidimAdmin.createDynamicFields;
  var createSortList = _exports$DecidimAdmin.createSortList;
  var attachGeocoding = window.Decidim.attachGeocoding;

  var wrapperSelector = ".meeting-services";
  var fieldSelector = ".meeting-service";

  var autoLabelByPosition = new AutoLabelByPositionComponent({
    listSelector: ".meeting-service:not(.hidden)",
    labelSelector: ".card-title span:first",
    onPositionComputed: function onPositionComputed(el, idx) {
      $(el).find("input[name$=\\[position\\]]").val(idx);
    }
  });

  var autoButtonsByPosition = new AutoButtonsByPositionComponent({
    listSelector: ".meeting-service:not(.hidden)",
    hideOnFirstSelector: ".move-up-service",
    hideOnLastSelector: ".move-down-service"
  });

  var createSortableList = function createSortableList() {
    createSortList(".meeting-services-list:not(.published)", {
      handle: ".service-divider",
      placeholder: '<div style="border-style: dashed; border-color: #000"></div>',
      forcePlaceholderSize: true,
      onSortUpdate: function onSortUpdate() {
        autoLabelByPosition.run();
      }
    });
  };

  var hideDeletedService = function hideDeletedService($target) {
    var inputDeleted = $target.find("input[name$=\\[deleted\\]]").val();

    if (inputDeleted === "true") {
      $target.addClass("hidden");
      $target.hide();
    }
  };

  createDynamicFields({
    placeholderId: "meeting-service-id",
    wrapperSelector: wrapperSelector,
    containerSelector: ".meeting-services-list",
    fieldSelector: fieldSelector,
    addFieldButtonSelector: ".add-service",
    removeFieldButtonSelector: ".remove-service",
    moveUpFieldButtonSelector: ".move-up-service",
    moveDownFieldButtonSelector: ".move-down-service",
    onAddField: function onAddField() {
      createSortableList();

      autoLabelByPosition.run();
      autoButtonsByPosition.run();
    },
    onRemoveField: function onRemoveField() {
      autoLabelByPosition.run();
      autoButtonsByPosition.run();
    },
    onMoveUpField: function onMoveUpField() {
      autoLabelByPosition.run();
      autoButtonsByPosition.run();
    },
    onMoveDownField: function onMoveDownField() {
      autoLabelByPosition.run();
      autoButtonsByPosition.run();
    }
  });

  createSortableList();

  $(fieldSelector).each(function (idx, el) {
    var $target = $(el);

    hideDeletedService($target);
  });

  autoLabelByPosition.run();
  autoButtonsByPosition.run();

  var $form = $(".edit_meeting, .new_meeting, .copy_meetings");

  if ($form.length > 0) {
    (function () {
      var $privateMeeting = $form.find("#private_meeting");
      var $transparent = $form.find("#transparent");

      var toggleDisabledHiddenFields = function toggleDisabledHiddenFields() {
        var enabledPrivateSpace = $privateMeeting.find("input[type='checkbox']").prop("checked");
        $transparent.find("input[type='checkbox']").attr("disabled", "disabled");

        if (enabledPrivateSpace) {
          $transparent.find("input[type='checkbox']").attr("disabled", !enabledPrivateSpace);
        }
      };

      $privateMeeting.on("change", toggleDisabledHiddenFields);
      toggleDisabledHiddenFields();

      attachGeocoding($form.find("#meeting_address"));

      var $meetingRegistrationType = $form.find("#meeting_registration_type");
      var $meetingRegistrationTerms = $form.find("#meeting_registration_terms");
      var $meetingRegistrationUrl = $form.find("#meeting_registration_url");
      var $meetingAvailableSlots = $form.find("#meeting_available_slots");

      var toggleDependsOnSelect = function toggleDependsOnSelect($target, $showDiv, type) {
        var value = $target.val();
        $showDiv.toggle(value === type);
      };

      $meetingRegistrationType.on("change", function (ev) {
        var $target = $(ev.target);
        toggleDependsOnSelect($target, $meetingAvailableSlots, "on_this_platform");
        toggleDependsOnSelect($target, $meetingRegistrationTerms, "on_this_platform");
        toggleDependsOnSelect($target, $meetingRegistrationUrl, "on_different_platform");
      });

      $meetingRegistrationType.trigger("change");
    })();
  }

  var $meetingForm = $(".meetings_form");
  if ($meetingForm.length > 0) {
    (function () {
      var $meetingTypeOfMeeting = $meetingForm.find("#meeting_type_of_meeting");
      var $meetingOnlineFields = $meetingForm.find(".field[data-meeting-type='online']");
      var $meetingInPersonFields = $meetingForm.find(".field[data-meeting-type='in_person']");

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
    })();
  }
})(window);
