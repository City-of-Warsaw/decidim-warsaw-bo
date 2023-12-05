// reload
$('label[for="project_budget_value"]').parent().find('.help-text').append('<span class="limit-info limit-info-js"></span>');
var selected_limit = parseInt($('#project_scope_id option:selected').data('limit'));
var budget_value = parseInt($('.budget-value-js').val());
handle_limit_value(selected_limit, budget_value);

$('.budget-value-js').on('keypress', function(e) {
    if ((e.keyCode < 48) || (57 < e.keyCode)) {
        e.preventDefault();
    }
});

$('.budget-value-js').on('keyup', function(e) {
   var selected_limit = parseInt($('#project_scope_id option:selected').data('limit'));
   var budget_value = parseInt($('.budget-value-js').val());

   handle_limit_value(selected_limit, budget_value);
});

$('#project_scope_id').on('change', function() {
    var selected_limit = parseInt($('#project_scope_id option:selected').data('limit'));
    var budget_value = parseInt($('.budget-value-js').val());

   handle_limit_value(selected_limit, budget_value);
});


function handle_limit_value(selected_limit, budget_value) {
    if (Number.isInteger(selected_limit) && Number.isInteger(budget_value)) {
        var selected_limit_s = selected_limit.toString().replace(/\d{1,3}(?=(\d{3})*$)/g, '$& ');
        if (budget_value > selected_limit) {
            var limit_info = 'Liczba nie może być większa niż ' + selected_limit_s;
            $('.limit-info-js').text(limit_info);
            // $('.limit-info-js').addClass('text-alert').text(limit_info);
        } else {
            var limit_info = 'Liczba nie może być większa niż '+ selected_limit_s;
            $('.limit-info-js').removeClass('text-alert').text(limit_info);
        }
    } else if (Number.isInteger(selected_limit)) {
        var selected_limit_s = selected_limit.toString().replace(/\d{1,3}(?=(\d{3})*$)/g, '$& ');
        var limit_info = 'Liczba nie może być większa niż '+ selected_limit_s;
        $('.limit-info-js').removeClass('text-alert').text(limit_info);
    } else {
        $('.limit-info-js').removeClass('text-alert').text('Liczba nie może być większa niż (musisz najpierw wybrać poziom)');
    }
}

$('form').on('submit', function() {
    var selected_limit = parseInt($('#project_scope_id option:selected').data('limit'));
    var budget_value = parseInt($('.budget-value-js').val());
    var selected_limit_s = selected_limit.toString().replace(/\d{1,3}(?=(\d{3})*$)/g, '$& ');

    if (budget_value > selected_limit) {
        var limit_info = 'Przypominamy, że limit kwoty dla jednego projektu dla wybranego poziomu wynosi: ' + selected_limit_s + 'zł.';
        alert(limit_info);
    }
});
