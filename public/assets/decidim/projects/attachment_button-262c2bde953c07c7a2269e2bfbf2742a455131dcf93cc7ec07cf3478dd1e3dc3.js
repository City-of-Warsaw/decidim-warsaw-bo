"use strict";

(function (exports) {
  var $ = exports.$; // eslint-disable-line

  $(function () {

    if ($('.edit_project').length > 0) {
      var form = $(".edit_project");
    } else {
      var form = $(".new_project");
    }

    var $form = form;

    if ($form.length > 0) {
      $('.attachment-button-js').click(function (e) {
        e.preventDefault();

        var target_id = $(this).data('target');
        $(target_id + " > input").last().click();
      });
    }
  });
})(window);
