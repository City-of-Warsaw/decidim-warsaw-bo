$(document).ready(function() {
    $('.check-password-strength-js').keyup(function() {
        checkPasswordStrength($(this));
    });

    $('.password-confirmation-js').keyup(function() {
        var password_field = $($(this).data('password'));
        checkPasswordStrength(password_field);
    });
});

function checkPasswordStrength(password_field) {
    var text = password_field.val();

    var length = document.getElementById('length');
    var lowercase = document.getElementById('lowercase');
    var uppercase = document.getElementById('uppercase');
    var number = document.getElementById('number');
    var special = document.getElementById('special');

    var ruleSuccessClass = "password-rule-success";

    checkIfTenChar(text) ? length.classList.add(ruleSuccessClass) : length.classList.remove(ruleSuccessClass);
    checkIfOneLowercase(text) ? lowercase.classList.add(ruleSuccessClass) : lowercase.classList.remove(ruleSuccessClass);
    checkIfOneUppercase(text) ? uppercase.classList.add(ruleSuccessClass) : uppercase.classList.remove(ruleSuccessClass);
    checkIfOneDigit(text) ? number.classList.add(ruleSuccessClass) : number.classList.remove(ruleSuccessClass);
    checkIfOneSpecialChar(text) ? special.classList.add(ruleSuccessClass) : special.classList.remove(ruleSuccessClass);

    checkPasswordConfirmation(password_field);

    // var final_score = checkIfTenChar(text) && checkIfOneLowercase(text) && checkIfOneUppercase(text) && checkIfOneDigit(text) && checkIfOneSpecialChar(text);
    // if ( final_score )   {
    //     $('#registration_user_password').removeClass('is-invalid-input');
    // } else {
    //     $('#registration_user_password').addClass('is-invalid-input');
    // }
}

function checkIfTenChar(text){
    return text.length >= 10;
}

function checkIfOneLowercase(text) {
    return /[a-z]/.test(text);
}

function checkIfOneUppercase(text) {
    return /[A-Z]/.test(text);
}

function checkIfOneDigit(text) {
    return /[0-9]/.test(text);
}

function checkIfOneSpecialChar(text) {
    return /[@~`!#$%£§\^&*+=\-\[\]\\';,\./_{}()|\\":<>\?]/g.test(text);
}

function checkPasswordConfirmation(password) {
    var passwordConfirmation = $(password.data('confirmation'));
    $('.passwordConfirmationMsg').remove();

    var msg = $('<span></span>').addClass('passwordConfirmationMsg');

    if (passwordConfirmation.val() === password.val()) {
        msg.html('hasła zgadzają się').removeClass('form-error');
    } else {
        msg.html('nie zgadza się z polem Hasło').addClass('form-error');
    }

    passwordConfirmation.parent().append(msg);
}
;
