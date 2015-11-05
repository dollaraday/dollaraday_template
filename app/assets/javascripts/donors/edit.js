// Donor "change billing details" /  "fix card" page

$(function() {

  $NS = $('body#donors_edit, body#donors_update');

  if (!$NS.length) {
    return false;
  }

  var $new_donor_form = $('form#edit_donor');

  $new_donor_form.submit(function(event) {
    var $form = $(this);

    // Disable the submit button to prevent repeated clicks
    $form.find('input[type=button]').prop('disabled', true);

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
        // and submit
        $form.get(0).submit();
      }
    });

    // Prevent the form from submitting with the default action
    return false;
  });

});
