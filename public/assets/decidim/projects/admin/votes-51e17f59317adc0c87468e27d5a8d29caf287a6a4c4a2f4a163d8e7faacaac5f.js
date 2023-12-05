// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function () {
    $('.fetch-projects-via-scope-js select').on( 'change', function(e) {
        let scope_id = $(this).val();
        let href = $('.fetch-projects-via-scope-js').data('href');
        $.get(href, {scope_id: scope_id}, null, 'script');
    });
});
