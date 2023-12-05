$(document).ready(function () {
  console.log("load page!");

  // always pass csrf tokens on ajax calls
  $.ajaxSetup({
    headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content') }
  });

  addEventListener('popstate', (event) => {
    console.log("popstate!");
  });

  let href = $('.card-votes-url-js').val();
  $.get(href, {}, function(data) {
    console.log('przed aktualizacja: ', $('input[class="selected-projects-js"]').val() )
    $('input[class="selected-projects-js"]').val( data['ids'] );

    updateLocalStorage();
    updateCounter();
    preselectProjects();
  });

   
  // listenToLocalStorage();

  $('.choose-projects-js').click( function(e) {
    e.preventDefault();
    document.getElementById("content").scrollIntoView();
    $('#search-projects-submit').click();

    //toggleInstructionWithProjects();
  });

  $('.map-toggler-js').click( function(e) {
    e.preventDefault();
    mapToggle();
  });

  $("select[multiple]").multiselect({
    columns: 1,
    search: false,
    selectAll: true,
    placeholder: 'Wybierz',
    showCheckbox: false,
    texts: {
      search         : 'Szukaj',
      selectedOptions: ' wybrano',
      selectAll      : 'Zaznacz wszystkie',
      unselectAll    : 'Odznacz wszystkie',
      noneSelected   : 'Nie zaznaczono'
    },
    // onControlClose: function (el) {
    //   $(el).parents('form').submit();
    // },
  });
 
  // choosing scope for district voting
  $('#wizard_vote_district_projects_scope_id').change(function () {
    let href = $(this).data('href');
    let scope_id = $(this).val();
    $.post(href, {_method: 'get', remote: true, scope_id: scope_id}, preselectProjects, "script");
  });

  // search
  $('.vote-wizard-search-js').click( function(e) {
    e.preventDefault();
    let href = $(this).data('href');
    let scope_id = $('.scope-id-js').val();
    let categories = $('.category-id-js').val();
    let recipients = $('.recipients-id-js').val();
    let text = $('.wizard-vote-search-text-js').val();

    $.post(href, {
      _method: 'get',
      remote: true,
      scope_id: scope_id,
      search_text: text,
      categories: categories,
      recipients: recipients
    }, preselectProjects, "script");
  });

  // cancel voting - button
  $('.vote-cancel-js').click( function(e) {
    e.preventDefault();
    $('#cancel-voting-modal').closest('.reveal-overlay').show();
    $('#cancel-voting-modal').show();
  });

  $('.choose-project-js').click(selectProject);

  $('.toggle-show-chosen-js').click(function(e) {
    e.preventDefault();
    
    let chosen = $(this).hasClass('chosen');
    let text = $(this).hasClass('chosen') ? $(this).data('chosen') : $(this).data('all'); 

    $(this).toggleClass('chosen'); 
    $(this).text(text);
    
    const selectedProjectsInput = $('input[class="selected-projects-js"]');
    let selectedProjectsArray = selectedProjectsInput.val() ? selectedProjectsInput.val().split(",").map(value => parseInt(value)) : [];
    
    const projects = $('#projects-list').children();

    projects.each(function() {
        let project_id = $(this).data('id');

        if (!selectedProjectsArray.includes(project_id)){
            if (chosen) $(this).show();
            else $(this).hide();
        }
    })
  });

  $('.scope-id').on('mousedown', function(e) {
    e.preventDefault(); 
    
    const scopeIdSelect = $("select.scope-id-js");
    const currentScopeId = scopeIdSelect.val();

    if (currentScopeId) $(`.scope-id-option[data-id=${currentScopeId}]`).addClass('selected').siblings().removeClass('selected');

    $(".scope-id-warning").hide();
    toggleScopeIdDropdown();
    scopeIdSelect.focus();
    scopeIdSelect.toggleClass("opened");
  });

  $('.ms-options-wrap > button').on('mousedown', function(e) {
    const scopeIdDropdown = $('div[class="scope-id-dropdown"]');
    scopeIdDropdown.hide();

    const scopeIdSelect = $("select.scope-id-js");
    scopeIdSelect.removeClass("opened");
  });

  $('.scope-id-option').click(function() { 
    
    const scopeIdSelect = $("select.scope-id-js");
    const currentScopeId = scopeIdSelect.val();

    const scopeId = $(this).data('id');

    $(this).addClass('selected').siblings().removeClass('selected');

    if (currentScopeId && currentScopeId != scopeId) {
      $(".scope-id-warning").show();
    }
  });

  $('.scope-id-button-js').click(function(e) {
    e.preventDefault(); 
 
    const scopeIdSelect = $("select.scope-id-js");
    const selectedOption = $(".scope-id-option.selected");
    
    const scope_id = selectedOption.data('id');

    if (scope_id) {
      console.log('scope_id', scope_id);

      scopeIdSelect.val(scope_id).change(); 
      scopeIdSelect.removeClass("opened");

      resetSelectedProjects();
      toggleScopeIdDropdown();
      $(".scope-id-warning").hide();
    }
  });

  // close modals
  $('.vote-modal-js .close-button, .vote-modal-js .close-js').click( function(e) {
    e.preventDefault();
    $('.vote-modal-js').closest('.reveal-overlay').hide();
    $('.vote-modal-js').hide();
  });

  // pomija glosowanie na projekty dzielnicowe na widoku step_2_info
  $('.skip-district-projects-voting-js').click(function(event) {
    event.preventDefault();

    let votingState = localStorage.getItem("voting_state");
    let votingStateArray = votingState ? votingState.split(",").map(value => parseInt(value)) : [];
    if (votingStateArray.length === 0) {
      showDistrictNotSelectedModal();
    } else {
      showConfirmModal(this); // show modal_district_free_votes
    }
  });
  // "dalej" na widoku listy do glosowania projektow dzilnicowych
  $('form.edit_wizard_vote_district_projects').submit(function(event) {
    event.preventDefault();
    const selectedProjectsCounterValue = $('span[class="chosen-count-js"]').text();
    if (parseInt(selectedProjectsCounterValue) === 0) {
      showDistrictNotSelectedModal()
    } else {
      showConfirmModal(this); // show modal_district_free_votes
    }
  })
  // pomija glosowanie na projekty ogolnomiejskie
  $('.skip-global-projects-voting-js').click(function(event) {
    event.preventDefault();

    const selectedProjectsInput = $('input[class="district-projects-js"]');
    let selectedProjectsArray = selectedProjectsInput.val() ? selectedProjectsInput.val().split(",").map(value => parseInt(value)) : [];
    const selectedProjectsCounterValue = $('span[class="chosen-count-js"]').text();
    if (selectedProjectsArray.length + parseInt(selectedProjectsCounterValue) === 0) {
      showNoneProjectsSelectedModal();
    } else if (parseInt(selectedProjectsCounterValue) === 0) {
      showGlobalNotSelectedModal();
    } else {
      showConfirmModal(this); // show modal_votes_warning
    }
  })
  $('form.edit_wizard_vote_global_projects').submit(function(event) {
    event.preventDefault();

    const selectedProjectsInput = $('input[class="district-projects-js"]');
    let selectedProjectsArray = selectedProjectsInput.val() ? selectedProjectsInput.val().split(",").map(value => parseInt(value)) : [];
    const selectedProjectsCounterValue = $('span[class="chosen-count-js"]').text();

    if (selectedProjectsArray.length + parseInt(selectedProjectsCounterValue) === 0) {
      showNoneProjectsSelectedModal();
    } else if (parseInt(selectedProjectsCounterValue) === 0) {
      showGlobalNotSelectedModal();
    } else {
      showConfirmModal(this); // show modal_votes_warning
    }
   })


  // nie wybrano zadnych dzielnicowych projektow
  function showDistrictNotSelectedModal() {
    $('#district-not-selected-modal').closest('.reveal-overlay').show();
    $('#district-not-selected-modal').show();

      $('#district-not-selected-modal .proceed-vote-js').click(function(e) {
        e.preventDefault();
        if ($('.skip-district-projects-voting-js').attr('href')) {
          // na widoku info
          window.location.href = $('.skip-district-projects-voting-js').attr('href');
        } else {
          $('form.edit_wizard_vote_global_projects, form.edit_wizard_vote_district_projects').unbind('submit').submit();
        }
      });
  }
  // nie wybrano zadnych ogolnomiejskich projektow
  function showGlobalNotSelectedModal() {
    $('#global-not-selected-modal').closest('.reveal-overlay').show();
    $('#global-not-selected-modal').show();

    $('#global-not-selected-modal .proceed-vote-js').click(function(e) {
      e.preventDefault();
      if ($('.skip-global-projects-voting-js').attr('href')) {
        // na widoku info
        window.location.href = $('.skip-global-projects-voting-js').attr('href');
      } else {
        $('form.edit_wizard_vote_global_projects, form.edit_wizard_vote_district_projects').unbind('submit').submit();
      }
    });
  }
  function showNoneProjectsSelectedModal() {
    $('#none-projects-selected-modal').closest('.reveal-overlay').show();
    $('#none-projects-selected-modal').show();
  }

  // potwierdzenie o pozostalych glosach
  function showConfirmModal(obj) {
    console.log('showConfirmModal(obj)');
    const selectedProjectsCounterValue = $('span[class="chosen-count-js"]').text();
    const selectedProjectsLimit = $('span[class="limit-count-js"]').text();
    $('strong[class="remaining-votes-js"]').text(parseInt(selectedProjectsLimit) - parseInt(selectedProjectsCounterValue));

    if (parseInt(selectedProjectsCounterValue) < parseInt(selectedProjectsLimit)) {
      $('#confirm-modal').closest('.reveal-overlay').show();
      $('#confirm-modal').show();

      $('#confirm-modal .proceed-vote-js').click(function(e) {
        e.preventDefault();
        if ($('.skip-district-projects-voting-js').attr('href')) {
          // na widoku info dzielnicowych
          window.location.href = $('.skip-district-projects-voting-js').attr('href');
        } else if ($('.skip-global-projects-voting-js').attr('href')) {
          // na widoku info ogolnomiejskich
          window.location.href = $('.skip-global-projects-voting-js').attr('href');
        } else {
          $('form.edit_wizard_vote_global_projects, form.edit_wizard_vote_district_projects').unbind('submit').submit();
        }
      });
    } else $(obj).unbind('submit').submit();
  }

  const timeToTimeout = 60000 * 30; // czas do wygaśnięcia sesji
  const timeToAlert = 60000 * 25; // czas do pokazania licznika

  let sessionHasExpired = false;

  function checkIfActive() {
    if(!sessionHasExpired){
      const currentTimestamp = +new Date();
      const activeAt = parseInt(localStorage.getItem("activeAt"));  

      if(activeAt + timeToAlert < currentTimestamp && currentTimestamp < activeAt + timeToTimeout) {
        $('#session-control-modal').closest('.reveal-overlay').show();
        $('#session-control-modal').show(); 
      
        const timeLeft = new Date((activeAt + timeToTimeout - currentTimestamp));

        document.querySelector(".remaining-time-js").innerHTML = String(timeLeft.getMinutes()).padStart(2, "0") + ":" + String(timeLeft.getSeconds()).padStart(2, "0");
      } else if (activeAt + timeToTimeout < currentTimestamp) {
        // koniec sesji, tutaj można usunąć dane
        finishVoting();

        sessionHasExpired = true;
        $('#session-expired-modal').closest('.reveal-overlay').show();
        $('#session-expired-modal').show();
      } else {
        if (document.querySelector(".remaining-time-js").innerHTML) {
          // użytkownik wykonał akcję podczas odliczania / usunięcie licznika
          $('#session-control-modal').closest('.reveal-overlay').hide();
          $('#session-control-modal').hide();
          document.querySelector(".remaining-time-js").innerHTML = null;
        }
      } 
    }
  }

  const checkIfActiveInterval = setInterval(checkIfActive, 1000);

  $('.voting-not-finished-js').click(function(e) {
    e.preventDefault();
    window.removeEventListener('beforeunload', finishVotingNoRedirect, false);
    $(this).off();
    if ($(this).attr('href')) {
      window.location.href = $(this).attr('href');
    }
  })

});

window.addEventListener(
  'beforeunload',
  finishVotingNoRedirect,
  false
);

function mapToggle() {
  $('.map-toggler-box').toggle();
  map.invalidateSize();
  if ($('.map-toggler-box').is(":visible")) {
    localStorage.setItem("map_visible", 1);
  } else {
    localStorage.setItem("map_visible", 0);
  }
}

function finishVoting() {
  if ($('.wizard-voting-finish-js').length > 0) {
    let href = $('.wizard-voting-finish-js').data('href');
    $.get(href, {}, function(data) { window.location.replace(window.location.host)});
  }
}

function finishVotingNoRedirect() {
  console.log('finishVotingNoRedirect()');
  if ($('.wizard-voting-finish-js').length > 0) {
    let href = $('.wizard-voting-finish-js').data('href');
    $.get(href, {}, function(data) {}, 'script');
  }
}


// check if we return from project show (during voting process), fp = from project
function backingFromProject() {
  url = new URL(window.location.href);
  return !!url.searchParams.get('fp');
}
function backToMap() {
  return localStorage.getItem("map_visible") === '1'
}
// resetuje widocznosc mapy
function resetMapVisible() {
  localStorage.setItem("map_visible", 0);
}

// function toggleInstructionWithProjects() {
//   $('.step-introduction-js').toggle();
//   $('.scope-choosing-js').toggle();
//   $('.projects-choosing-js').toggle();
// }

function updateCounter() {
  console.log('updateCounter()');

  const selectedProjectsInput = $('input[class="selected-projects-js"]');
  let selectedProjectsArray = selectedProjectsInput.val() ? selectedProjectsInput.val().split(",").map(value => parseInt(value)) : [];

  const selectedProjectsCounter = $('span[class="chosen-count-js"]');
  selectedProjectsCounter.text(selectedProjectsArray.length.toString());

  const showChosenButton = $('button.toggle-show-chosen-js');

  if(selectedProjectsArray.length === 0) showChosenButton.prop("disabled", true);
  else showChosenButton.prop("disabled", false);

  $('input[class="selected-projects-js"]').trigger("change");

  // updateLocalStorage();
}

function preselectProjects() {
  console.log('preselectProjects()');

  const selectedProjectsInput = $('input[class="selected-projects-js"]');
  let selectedProjectsArray = selectedProjectsInput.val() ? selectedProjectsInput.val().split(",").map(value => parseInt(value)) : [];

  const projects = $('#projects-list').children();

  projects.each(function() {
      let project_id = $(this).data('id');
 
      const buttonTd = $(this).find(".choose-project-js");

      let text = !selectedProjectsArray.includes(project_id) ? 'Wybierz' : 'Zrezygnuj';
      selectedProjectsArray.includes(project_id) ? buttonTd.addClass('chosen') : buttonTd.removeClass('chosen');
      selectedProjectsArray.includes(project_id) ? $('.number-td-' + project_id + '-js').addClass('chosen') : $('.number-td-' + project_id + '-js').removeClass('chosen');
      buttonTd.text(text);
  })

  $("#projects-list .choose-project-js").each(function() { 
    $(this).on(
      "mouseenter",
      function() {  
        const highlightedProjectsInput = $('input[class="highlighted-projects-js"]');
        let highlightedProjectsArray = highlightedProjectsInput.val() ? highlightedProjectsInput.val().split(",").map(value => parseInt(value)) : [];

        const project_id = $(this).data("id");

        if (!highlightedProjectsArray.includes(project_id)) highlightedProjectsArray.push(project_id); 
        
        highlightedProjectsInput.val(highlightedProjectsArray);  
        highlightedProjectsInput.trigger("change");
      }
    ).on(
      "mouseleave",
      function() {
        const highlightedProjectsInput = $('input[class="highlighted-projects-js"]');
        let highlightedProjectsArray = highlightedProjectsInput.val() ? highlightedProjectsInput.val().split(",").map(value => parseInt(value)) : [];

        const project_id = $(this).data("id");

        if (highlightedProjectsArray.includes(project_id)) highlightedProjectsArray = highlightedProjectsArray.filter(value => value !== project_id); 
        
        highlightedProjectsInput.val(highlightedProjectsArray);  
        highlightedProjectsInput.trigger("change");
      }
    );
  });

  updateCounter();
}

function selectProject(e) {
  e.preventDefault();
  console.log('selectProject(e)');

  let projects = "";
  let href = $(this).attr('href')
  $.post(
    href,
    {_method: 'patch', remote: true, format: 'json'},
    function(data) {
      $('input[class="selected-projects-js"]').val(data["ids"]);
    },
    "json"
  );


  const selectedProjectsCounterValue = $('span[class="chosen-count-js"]').text();
  const selectedProjectsLimit = $('span[class="limit-count-js"]').text();

  if (!$(this).hasClass('chosen') && parseInt(selectedProjectsCounterValue) >= parseInt(selectedProjectsLimit)) return false;
    
  let text = $(this).hasClass('chosen') ? 'Wybierz' : 'Zrezygnuj'
  let project_id = $(this).data('id');

  $(this).toggleClass('chosen');
  $('.number-td-' + project_id + '-js').toggleClass('chosen');
  $(this).text(text);

  const selectedProjectsInput = $('input[class="selected-projects-js"]');
  let selectedProjectsArray = selectedProjectsInput.val() ? selectedProjectsInput.val().split(",").map(value => parseInt(value)) : [];

  if($(this).hasClass('chosen')) selectedProjectsArray.push(project_id);
  else selectedProjectsArray = selectedProjectsArray.filter(value => value !== project_id); 
  
  selectedProjectsInput.val(selectedProjectsArray);  

  updateCounter();
  updateLocalStorage();
} 

function resetSelectedProjects() {
  console.log('resetSelectedProjects()');

  const selectedProjectsInput = $('input[class="selected-projects-js"]');
  let selectedProjectsArray = selectedProjectsInput.val() ? selectedProjectsInput.val().split(",").map(value => parseInt(value)) : [];

  const projects = $('#projects-list').children();

  projects.each(function() {
      let project_id = $(this).data('id');

    console.log('selectedProjectsArray: ', selectedProjectsArray);
    console.log('project_id: ', project_id);

      if (selectedProjectsArray.includes(project_id)) {
        console.log('mamy!');
        const buttonTd = $(this).find(".choose-project-js");

        let text = buttonTd.hasClass('chosen') ? 'Wybierz' : 'Zrezygnuj';
        buttonTd.toggleClass('chosen');
        $('.number-td-' + project_id + '-js').toggleClass('chosen');
        buttonTd.text(text);
      }
  })

  selectedProjectsInput.val(undefined);
  updateCounter();
}

function toggleScopeIdDropdown() {
  const scopeIdDropdown = $('div[class="scope-id-dropdown"]');
  scopeIdDropdown.toggle();
}

function updateLocalStorage() {
  console.log('updateLocalStorage');
  const selectedProjectsInput = $('input[class="selected-projects-js"]');
  let selectedProjectsArray = selectedProjectsInput.val() ? selectedProjectsInput.val() : [];

  localStorage.setItem("voting_state", selectedProjectsArray); 
}

function listenToLocalStorage() {
  const interval = setInterval(function() {
    const votingState = localStorage.getItem("voting_state");
    const selectedProjectsInput = $('input[class="selected-projects-js"]'); 

    if (selectedProjectsInput.length > 0 && votingState !== selectedProjectsInput.val()) {
      selectedProjectsInput.val(votingState);

      preselectProjects();
    }
  }, 300);
}
;
