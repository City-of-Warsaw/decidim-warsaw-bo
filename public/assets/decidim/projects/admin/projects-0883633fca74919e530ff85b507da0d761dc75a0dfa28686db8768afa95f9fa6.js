'use strict';

$(document).ready(function () {
  var selectedProjectsCount = function selectedProjectsCount() {
    return $('.table-list .js-check-all-project:checked').length;
  };

  var selectedProjectsNotPublishedAnswerCount = function selectedProjectsNotPublishedAnswerCount() {
    return $('.table-list [data-published-state=false] .js-check-all-project:checked').length;
  };

  window.selectedProjectsCountUpdate = function () {
    var selectedProjects = selectedProjectsCount();
    var selectedProjectsNotPublishedAnswer = selectedProjectsNotPublishedAnswerCount();
    if (selectedProjects == 0) {
      $("#js-selected-projects-count").text("");
    } else {
      $("#js-selected-projects-count").text(selectedProjects);
    }

    if (selectedProjects >= 2) {
      $('button[data-action="merge-projects"]').parent().show();
    } else {
      $('button[data-action="merge-projects"]').parent().hide();
    }

    if (selectedProjectsNotPublishedAnswer > 0) {
      $('button[data-action="publish-answers"]').parent().show();
      $('#js-form-publish-answers-number').text(selectedProjectsNotPublishedAnswer);
    } else {
      $('button[data-action="publish-answers"]').parent().hide();
    }
  };

  var showBulkActionsButton = function showBulkActionsButton() {
    if (selectedProjectsCount() > 0) {
      $("#js-bulk-actions-button").removeClass('hide');
    }
  };

  window.hideBulkActionsButton = function () {
    var force = arguments.length <= 0 || arguments[0] === undefined ? false : arguments[0];

    if (selectedProjectsCount() == 0 || force == true) {
      $("#js-bulk-actions-button").addClass('hide');
      $("#js-bulk-actions-dropdown").removeClass('is-open');
    }
  };

  window.showOtherActionsButtons = function () {
    $("#js-other-actions-wrapper").removeClass('hide');
  };

  window.hideOtherActionsButtons = function () {
    $("#js-other-actions-wrapper").addClass('hide');
  };

  window.hideBulkActionForms = function () {
    $(".js-bulk-action-form").addClass('hide');
  };

  if ($('.js-bulk-action-form').length) {
    window.hideBulkActionForms();
    $("#js-bulk-actions-button").addClass('hide');

    $("#js-bulk-actions-dropdown ul li button").click(function (e) {
      e.preventDefault();
      var action = $(e.target).data("action");

      if (action) {
        $('#js-form-' + action).submit(function () {
          $('.layout-content > .callout-wrapper').html("");
        });

        $('#js-' + action + '-actions').removeClass('hide');
        window.hideBulkActionsButton(true);
        window.hideOtherActionsButtons();
      }
    });

    // select all checkboxes
    $(".js-check-all").change(function () {
      console.log('all..?');

      $(".js-check-all-project").prop('checked', $(this).prop("checked"));

      if ($(this).prop("checked")) {
        $(".js-check-all-project").closest('tr').addClass('selected');
        showBulkActionsButton();
      } else {
        $(".js-check-all-project").closest('tr').removeClass('selected');
        window.hideBulkActionsButton();
      }

      selectedProjectsCountUpdate();
    });

    // project checkbox change
    $('.table-list').on('change', '.js-check-all-project', function (e) {
      var project_id = $(this).val();
      var checked = $(this).prop("checked");

      // uncheck "select all", if one of the listed checkbox item is unchecked
      if ($(this).prop("checked") === false) {
        $(".js-check-all").prop('checked', false);
      }
      // check "select all" if all checkbox projects are checked
      if ($('.js-check-all-project:checked').length === $('.js-check-all-project').length) {
        $(".js-check-all").prop('checked', true);
        showBulkActionsButton();
      }

      if ($(this).prop("checked")) {
        showBulkActionsButton();
        $(this).closest('tr').addClass('selected');
      } else {
        window.hideBulkActionsButton();
        $(this).closest('tr').removeClass('selected');
      }

      if ($('.js-check-all-project:checked').length === 0) {
        window.hideBulkActionsButton();
      }

      $('.js-bulk-action-form').find(".js-project-id-" + project_id).prop('checked', checked);
      selectedProjectsCountUpdate();
    });

    $('.js-cancel-bulk-action').on('click', function (e) {
      window.hideBulkActionForms();
      showBulkActionsButton();
      showOtherActionsButtons();
    });
  }
});
