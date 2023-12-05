((exports) => {
  const $ = exports.$; // eslint-disable-line

  $(() => {
    if ( $('.edit_project').length > 0 ) {
      var form = $(".edit_project");
    } else if ($('.new_project_wizard_first_step_with_validation').length > 0 ) {
      var form = $(".new_project_wizard_first_step_with_validation");
    } else {
      var form = $(".new_project");
    }

    const $form = form;

    if ($form.length > 0) {
      const $universalFalse = $form.find("#project_universal_design_false");
      const $universalTrue = $form.find("#project_universal_design_true");
      const $showDiv = $form.find("#universal_design_argumentation");

      const toggleDependsOnSelect = ($target, $showDiv) => {

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

      $universalFalse.on('click', (e) => {
        toggleDependsOnSelect($universalFalse, $showDiv);
      });
      $universalTrue.on('click', (e) => {
        toggleDependsOnSelect($universalTrue, $showDiv);
      });

      if ($universalFalse.prop('checked')) {
        $showDiv.show();
      } else {
        $showDiv.hide();
      }
    }
  });
})(window);
