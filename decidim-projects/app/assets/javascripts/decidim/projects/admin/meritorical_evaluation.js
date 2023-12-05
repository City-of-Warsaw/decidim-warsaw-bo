$(document).ready(function () {

  // on reload
  set_meritorical_result();

  // 19 punktow oceny merytorycznej, zeby dzialaly jak radio
  $('.meritorical-evaluation-js input[type=checkbox]').click(function(e) {
    if ($(this).prop('checked')) {
      $(this).parent().parent().find('input[type=checkbox]').prop('checked', false)
      $(this).prop('checked', true);
    }
    set_meritorical_result();
  })

  // zmiana projektu, zeby dzialaly jak radio
  $('#changes_info-js input[type=checkbox]').click(function(e) {
    if ($(this).prop('checked')) {
      $(this).parent().parent().find('input[type=checkbox]').prop('checked', false)
      $(this).prop('checked', true);
    }
  })

  // scroll do błedów
  const targetNode = document.getElementsByTagName('form')[0];

  const config = { attributes: true, childList: false, subtree: true };
  const callback = (mutationList, observer) => {
    for (const mutation of mutationList) {
      if (mutation.type === 'attributes' && mutation.attributeName === "data-invalid") {
        mutation.target.scrollIntoView({behavior: "smooth", block: "center", inline: "nearest"});
      }
    }
  };

  const observer = new MutationObserver(callback);
  observer.observe(targetNode, config);
});


function set_meritorical_result() {
  var mapped = $('.meritorical-evaluation-js input[type=checkbox]').map( function() {
    if ($(this).prop('checked')) {
      return $(this).val();
    }
  }).get();

  // negatywna: jesli nic nie zostalo zaznaczone, albo jesli nei ma zadnej negatywnej oceny
  if (mapped.length > 0 && mapped.includes('2')) {
    $('#meritorical_evaluation_result_2').prop('checked', true);
    $('#meritorical_evaluation_result').val(2);
    $('#meritorical_evaluation_project_implementation_effects').prop('disabled', true)
    $('#meritorical_evaluation_result_description').prop('disabled', false)
    $('#meritorical_evaluation_estimate').prop('disabled', true)

  } else {
    // pozytywna
    $('#meritorical_evaluation_result_1').prop('checked', true);
    $('#meritorical_evaluation_result').val(1);
    $('#meritorical_evaluation_project_implementation_effects').prop('disabled', false)
    $('#meritorical_evaluation_result_description').prop('disabled', true)
    $('#meritorical_evaluation_estimate').prop('disabled', false)
  }
}
