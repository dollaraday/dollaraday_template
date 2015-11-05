$(function() {

  $NS = $('body#donors_new, body#donors_create');

  if (!$NS.length) {
    return false;
  }

  window.checking_for_existing_donors = false;

  // Donor Form Step 1: check if donor exists
  var $new_donor_form = $('form#new_donor'),
    $new_donor_email = $new_donor_form.find('input#donor_card_attributes_email'),
    $existing_donor_message = $('#existing_donor_message'),
    cached_email_lookups = {}; //  { 'a@a.com': false, 'b@b.com': "You're already ... "}

  $new_donor_form.submit(function(event) {
    var $form = $(this),
      $name = $form.find("#donor_card_attributes_name"),
      $email = $form.find("#donor_card_attributes_email");


    // Disable the submit button to prevent repeated clicks
    $form.find('input[type=button]').prop('disabled', true);

    // Stripe doesn't validate any email field
    if (!validateEmail($email.val())) {
      $form.find('.payment-errors').text("Please enter your email.");
      $form.find('input[type=button]').prop('disabled', false);
      return false;
    }

    // Don't send email to Stripe
    $email.prop('disabled', true);

    // Stripe doesn't validate any name field
    if (!$name.val().length) {
      $form.find('.payment-errors').text("Please enter your name.");
      $form.find('input[type=button]').prop('disabled', false);
      return false;
    }

    Stripe.card.createToken($form, function (status, response) {
      if (response.error) {
        // Show the errors on the form
        $form.find('.payment-errors').text(response.error.message);
        $form.find('input[type=button]').prop('disabled', false);
      } else {
        // response contains id and card, which contains additional card details
        var token = response.id;
        // Insert the token into the form so it gets submitted to the server
        $form.append($('<input type="hidden" name="stripeToken" />').val(token));
        $email.prop('disabled', false);
        // and submit
        $form.get(0).submit();
      }
    });

    // Prevent the form from submitting with the default action
    return false;
  });


  $('input#donor_card_attributes_email, input#donor_verification_email').on('input', function (e) {
    if (window.checking_for_existing_donors) { return false; }

    var $field = $(this),
      email = $(this).val();

    if (email in cached_email_lookups) {
      if (cached_email_lookups[email]) {
        $("#donor_verification_email").val(email);
        $existing_donor_message.show().find('span').text(cached_email_lookups[email]);
      } else {
        $existing_donor_message.hide();
      }
    } else if (/.*@.*/.test(email)) {
      window.checking_for_existing_donors = true;

      $.ajax({
        url: '/donors/exists.json',
        data: {email: email},
        async: true,
        success: function (data, status, xhr) {
          window.checking_for_existing_donors = false;
          cached_email_lookups[email] = data.success === true ? data.message : false;

          if (data.success === true) {
            $("#donor_verification_email").val(email);
            $existing_donor_message.show().find('span').text(cached_email_lookups[email]);
          } else {
            $existing_donor_message.hide();
          }
        }
      });
    } else {
      $existing_donor_message.hide();
    }
  });
});
