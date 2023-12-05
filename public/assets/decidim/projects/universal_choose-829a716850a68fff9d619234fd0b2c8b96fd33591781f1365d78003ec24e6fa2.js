'use strict';

(function (exports) {
  var $ = exports.$; // eslint-disable-line

  $(function () {
    if ($('.edit_project').length > 0) {
      var form = $(".edit_project");
    } else if ($('.new_project_wizard_first_step_with_validation').length > 0) {
      var form = $(".new_project_wizard_first_step_with_validation");
    } else {
      var form = $(".new_project");
    }

    var $form = form;

    if ($form.length > 0) {
      (function () {
        var $universalFalse = $form.find("#project_universal_design_false");
        var $universalTrue = $form.find("#project_universal_design_true");
        var $showDiv = $form.find("#universal_design_argumentation");

        var toggleDependsOnSelect = function toggleDependsOnSelect($target, $showDiv) {

          // if ($target === $universalFalse) {
          //   $showDiv.show();
          // } else {
          //   $showDiv.hide();
          // }
          if ($universalFalse.prop('checked')) {
            $showDiv.show();
          } else {
            $showDiv.hide();
          }
        };

        $universalFalse.on('click', function (e) {
          toggleDependsOnSelect($universalFalse, $showDiv);
        });
        $universalTrue.on('click', function (e) {
          toggleDependsOnSelect($universalTrue, $showDiv);
        });

        if ($universalFalse.prop('checked')) {
          $showDiv.show();
        } else {
          $showDiv.hide();
        }
      })();
    }
  });
})(window);
