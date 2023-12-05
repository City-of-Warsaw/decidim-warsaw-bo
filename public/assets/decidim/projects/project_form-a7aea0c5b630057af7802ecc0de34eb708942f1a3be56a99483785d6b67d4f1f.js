$(document).ready(function () {
  // projektowanie uniwersalne
  $('.universal-design-js input[type=checkbox]').click(function(e) {
    if ($(this).prop('checked')) {
      $(this).parent().parent().find('input[type=checkbox]').prop('checked', false)
      $(this).prop('checked', true);
    }
  })

});
