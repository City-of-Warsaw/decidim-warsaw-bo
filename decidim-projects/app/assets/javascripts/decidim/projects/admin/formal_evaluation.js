$(document).ready(function () {

  // on reload
  set_formal_result();
  list_out_the_negative_reasons();

  $('.formal-evaluation-table-js input').click( function(e) {
    set_formal_result(); 

    if( $(this).attr('type') === "radio") {
      if($(this).val() == 2) {
        $(this).closest("tr").find("input[type=checkbox]").attr("disabled", false);
      } else {
        $(this).closest("tr").find("input[type=checkbox]").attr("disabled", true);
        $(this).closest("tr").find("input[type=checkbox]").prop("checked", false);
      }
    }
  });
});


function set_formal_result() {
  var mapped = $('.formal-evaluation-table-js .formal-not-ok-js').map( function() {
    if ($(this).data('correctable')) {
      correctable = $($(this).data('correctable'));
      if (correctable.prop('checked')) {
        return false;
      } else {
        return this.checked;
      }
    } else {
      return this.checked;
    }
  }).get();

  if (mapped.includes(true)) {
    $('#formal_evaluation_result_2').prop('checked', true);
    $('#formal_evaluation_result').val(2);
    $('.result-negative-js').show();
    // showing list of negative reasons
    list_out_the_negative_reasons();
  } else {
    $('#formal_evaluation_result_1').prop('checked', true);
    $('#formal_evaluation_result').val(1);
    $('.result-negative-js').hide();
    // clearing list
    $('.result-negative-js ul').html('');
  }
}

function list_out_the_negative_reasons() {
  var mapped_reasons = $('.formal-evaluation-table-js .formal-not-ok-js').map( function() {
    if ($(this).data('correctable')) {
      correctable = $($(this).data('correctable'));
      if (correctable.prop('checked')) {
      } else if (this.checked) {
        return $(this).data('reason');
      }
    } else if (this.checked) {
      return $(this).data('reason');
    }
  }).get();

  $('.result-negative-js ul').html('');
  $.each(mapped_reasons, function() {
    $('.result-negative-js ul').append('<li>' + this + '</li>');
  });
}
