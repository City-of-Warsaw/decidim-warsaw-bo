"use strict";

$(function () {
  var checkProgressPosition = function checkProgressPosition() {
    var progressFix = document.querySelector("[data-progressbox-fixed]"),
        progressRef = document.querySelector("[data-progress-reference]"),
        progressVisibleClass = "is-progressbox-visible";

    if (!progressRef) {
      return;
    }

    var progressPosition = progressRef.getBoundingClientRect().bottom;
    if (progressPosition > 0) {
      progressFix.classList.remove(progressVisibleClass);
    } else {
      progressFix.classList.add(progressVisibleClass);
    }
  };

  window.addEventListener("scroll", checkProgressPosition);

  window.DecidimBudgets = window.DecidimBudgets || {};
  window.DecidimBudgets.checkProgressPosition = checkProgressPosition;
});
"use strict";

$(function () {
  var $projects = $("#projects, #project");
  var $budgetSummaryTotal = $(".budget-summary__total");
  var $budgetExceedModal = $("#budget-excess");
  var $budgetSummary = $(".budget-summary__progressbox");
  var totalAllocation = parseInt($budgetSummaryTotal.attr("data-total-allocation"), 10);

  var cancelEvent = function cancelEvent(event) {
    event.stopPropagation();
    event.preventDefault();
  };

  var allowExitFrom = function allowExitFrom($el) {
    if ($el.parents("#loginModal").length > 0) {
      return true;
    } else if ($el.parents("#authorizationModal").length > 0) {
      return true;
    }

    return false;
  };

  $projects.on("click", ".budget-list__action", function (event) {
    var currentAllocation = parseInt($budgetSummary.attr("data-current-allocation"), 10);
    var $currentTarget = $(event.currentTarget);
    var projectAllocation = parseInt($currentTarget.attr("data-allocation"), 10);

    if ($currentTarget.attr("disabled")) {
      cancelEvent(event);
    } else if ($currentTarget.attr("data-add") === "true" && currentAllocation + projectAllocation > totalAllocation) {
      $budgetExceedModal.foundation("toggle");
      cancelEvent(event);
    }
  });

  if ($("#order-progress [data-toggle=budget-confirm]").length > 0) {
    (function () {
      var safeUrl = $(".budget-summary").attr("data-safe-url").split("?")[0];
      $(document).on("click", "a", function (event) {
        if (allowExitFrom($(event.currentTarget))) {
          window.exitUrl = null;
        } else {
          window.exitUrl = event.currentTarget.href;
        }
      });
      $(document).on("submit", "form", function (event) {
        if (allowExitFrom($(event.currentTarget))) {
          window.exitUrl = null;
        } else {
          window.exitUrl = event.currentTarget.action;
        }
      });

      window.addEventListener("beforeunload", function (event) {
        var currentAllocation = parseInt($budgetSummary.attr("data-current-allocation"), 10);
        var exitUrl = window.exitUrl;
        window.exitUrl = null;

        if (currentAllocation === 0 || exitUrl && exitUrl.startsWith(safeUrl)) {
          return;
        }

        event.returnValue = true;
      });
    })();
  }
});
