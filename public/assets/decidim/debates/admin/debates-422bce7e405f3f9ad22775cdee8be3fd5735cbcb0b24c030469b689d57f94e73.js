"use strict";

(function (exports) {
  var createFieldDependentInputs = exports.DecidimAdmin.createFieldDependentInputs;

  var $debateType = $('[name="debate[finite]"');

  createFieldDependentInputs({
    controllerField: $debateType,
    wrapperSelector: ".debate-fields",
    dependentFieldsSelector: ".debate-fields--open",
    dependentInputSelector: "input",
    enablingCondition: function enablingCondition() {
      return $("#debate_finite_false").is(":checked");
    }
  });

  createFieldDependentInputs({
    controllerField: $debateType,
    wrapperSelector: ".debate-fields",
    dependentFieldsSelector: ".debate-fields--finite",
    dependentInputSelector: "input",
    enablingCondition: function enablingCondition() {
      return $("#debate_finite_true").is(":checked");
    }
  });
})(window);
