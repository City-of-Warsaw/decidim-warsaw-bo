/**
 * Words Limit
 */

var wordsLimitInfo = 'Limit słów: ';
var wordsLimitLeft = 'Pozostało słów: ';

$('.words-limit').after(function() {
  var el = $(this);
  return '<div class="words-limit-info">'+ wordsLimitInfo + el.data('limit') +'</div>';
});

function wordsLimitCheck() {
  var el = $(this);
  var limit = el.data('limit');
  var text = el.val().trim();
  var limited;

  var wordcount = text.length === 0 ? 0 : text.split(/[\s]+/).length; 

  if (wordcount > limit) {
    el.siblings(".words-limit-info").html(wordsLimitLeft+ ' 0').addClass('error');
    limited = text.split(/[\s]+/, limit);
    limited = limited.join(" ");
    el.val(limited);
  } else {
    el.siblings(".words-limit-info").html(wordsLimitLeft+ '' +(limit - wordcount)).removeClass('error');
  }
};

$('.words-limit').each(wordsLimitCheck);
$('.words-limit').on('keyup', wordsLimitCheck);