$(document).ready(function () {

  // on reload
  set_reevaluation_result();

  $('input[name="reevaluation[reevaluation_result]"][type="radio"]').on('change', function(e) {
    set_reevaluation_result();
  });
});


function set_reevaluation_result() {
  var r_pos = $('#reevaluation_reevaluation_result_1').prop('checked');
  var r_neg = $('#reevaluation_reevaluation_result_2').prop('checked');
  // var final_r_pos = $('#reevaluation_result_true');
  // var final_r_neg = $('#reevaluation_result_false');

  if (r_pos) {
    $('#reevaluation_positive_reevaluation_body').attr('disabled', false);
    $('#reevaluation_negative_reevaluation_body').attr('disabled', true);
    $('#reevaluation_negative_reevaluation_body').removeClass('is-invalid-input');
    $('#reevaluation_negative_reevaluation_body').closest('label').removeClass('is-invalid-label');
    $('#reevaluation_negative_reevaluation_body').closest('label').find('small').removeClass('is-visible');
  } else if (r_neg) {
    $('#reevaluation_positive_reevaluation_body').attr('disabled', true);
    $('#reevaluation_positive_reevaluation_body').removeClass('is-invalid-input');
    $('#reevaluation_positive_reevaluation_body').closest('label').removeClass('is-invalid-label');
    $('#reevaluation_positive_reevaluation_body').closest('label').find('small').removeClass('is-visible');
    $('#reevaluation_negative_reevaluation_body').attr('disabled', false);
  } else {
    $('#reevaluation_positive_reevaluation_body').attr('disabled', true);
    $('#reevaluation_positive_reevaluation_body').removeClass('is-invalid-input');
    $('#reevaluation_positive_reevaluation_body').closest('label').removeClass('is-invalid-label');
    $('#reevaluation_positive_reevaluation_body').closest('label').find('small').removeClass('is-visible');
    $('#reevaluation_negative_reevaluation_body').attr('disabled', true);
    $('#reevaluation_negative_reevaluation_body').removeClass('is-invalid-input');
    $('#reevaluation_negative_reevaluation_body').closest('label').removeClass('is-invalid-label');
    $('#reevaluation_negative_reevaluation_body').closest('label').find('small').removeClass('is-visible');
  }
}
