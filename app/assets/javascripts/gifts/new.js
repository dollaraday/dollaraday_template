$(function () {

  var $NS = $('body#gifts_new, body#gifts_create'),
    $gift_list_container = $('.js-gift-list-container'),
    $gift_list = $('.js-gift-list'),
    position = 5,
    hero_timeout_handler;

  if (!$NS.length) {
    return;
  }

  function rotate_hero_adjectives() {
    var $gift_item = $gift_list.find('.js-gift-word').eq(position);

    $gift_list.find('.js-gift-item').removeClass('active');
    $gift_item.addClass('active');

    $gift_list_container.css({
      'height': $gift_item.outerHeight(true) - 16,
      'width' : $gift_item.find('span').width()
    });

    $gift_list.css({
      'top': -$gift_item.position().top
    });
  }

  function reset_hero_timer () {
    clearInterval(hero_timeout_handler);
    hero_timeout_handler = setInterval(function () {
      next_hero_adjective();
    }, 4000);
  }

  function next_hero_adjective () {
    position++;
    if (position >= $gift_list.find('.js-gift-word').length) {
      position = 0;
    }

    rotate_hero_adjectives();
  }


  $(document).resize(function () {
    rotate_hero_adjectives();
  });

  // Delay this so the text animation is more apparent
  window.setTimeout(function () {
    $gift_list_container.removeClass('opacity-0');
    rotate_hero_adjectives();
  }, 500);

  reset_hero_timer();


  $('.js-field-container').height($(this).find('.js-recipient-name').outerHeight());
  $('.js-recipient-email').fadeIn();

  function scroll_to_div ($div, previous_div) {

    if (previous_div != null) {
      // Fade in the next step
      $div.fadeIn(300, function () {
        $(previous_div).animate({
          'marginTop': -$(previous_div).outerHeight()
        }, 400, 'easeOutExpo', function () {
          $(previous_div).fadeOut();
        });
      });
    } else {

      $div.fadeIn(300, function () {
        $div.animate({
          'marginTop': 0
        });
        $('.js-section').not($div)
          .fadeOut()
          .css({ 'marginTop' : 0 });
      });
    }

  }

  function transition_name_to_email () {
    $('.js-input-fields').css({
      'marginTop': -($('.js-recipient-name').outerHeight())
    });

    $('.js-recipient-name-errors').hide();
    $('.js-recipient-email-errors').show();

    $('.js-input-fields').addClass('js-email-visible');
  }


  // Next/previous functionality

  $('.js-next-step').on('click', function (e) {

    $scroll_div = $NS.find($(this).attr('href'));

    if ($(this).closest('section').attr('id') == 'step1') {
      input_name = $('#step1').find('input').val();

      var name = $('.js-recipient-name').val().trim(),
        email = $('.js-recipient-email').val().trim();

      if ($('.js-email-visible').length) {
        if (email === '') {
          $('.js-recipient-email').val("");
          $('.js-recipient-email-errors').text("Please enter an email.").show();
        } else if (name != '' && email != '') {
          $NS.find('.js-name').text(input_name);
          // Test to see if the email seems valid
          if (!/(.+)@(.+){2,}\.(.+){2,}/.test(email)) {
            $('.js-recipient-email-errors').text("Please enter a valid email.").show();
          } else {
            $.ajax({
              dataType: "json",
              url: '/gifts/exists.json',
              data: {email: email},
              async: false,
              success: function (data, status, xhr) {
                if (data.success) { // donor already exists
                  $('.js-recipient-email-errors').text(data.message).show();
                } else {
                  scroll_to_div($scroll_div, '#step1');
                }
              }
            });
          }
        }
      }

      if ($('.js-recipient-name').val().trim() != '') {
        transition_name_to_email();
      } else {
        $('.js-recipient-name').val("");
        $('.js-recipient-name-errors').text("Please enter a name.");
        $('.js-recipient-email-errors').show();
      }

    } else if ($(this).closest('section').attr('id') == 'step2') {
      // Select the length you want to give for and store it in a hidden input
      var length = $(this).data('giving-length'),
        $selected_gift_text = $NS.find('.js-gift-message-text[data-giving-length="' + length + '"]');;

      $NS.find('.js-giving-length').val(length);
      $selected_gift_text.show();
      $NS.find('.js-gift-message').val($selected_gift_text.text());

      scroll_to_div($scroll_div, '#step2');

    }

    e.preventDefault();
  });


  $('.js-reset').on('click', function (e) {

    $('.js-input-fields')
      .removeClass('js-email-visible')
      .css({'marginTop': 0 });

    scroll_to_div($NS.find($(this).attr('href')));

    // Reset form values
    $NS.find('.js-giving-length, .js-recipient-name, .js-recipient-email, .js-gift-message').val('');
    $NS.find('.js-gift-message-text, .js-gift-message').hide();

    e.preventDefault();
  });


  $('.js-empty-input').find('.js-recipient-name, .js-recipient-email').on('focus', function () {
    $('.js-empty-input').addClass('focus');
  });

  $('.js-empty-input').find('.js-recipient-name').on('blur', function () {
    $('.js-empty-input').removeClass('focus');
  });


  // Fill in name

  $('#donor_card_attributes_name').on('keyup change', function () {
    $('.js-from-name').text($(this).val());
  });

  // Show the message field
  $NS.find('.js-show-message-field').on('click', function (e) {
    $(this).hide();
    $('.js-gift-message')
      .val($NS.find('.js-gift-message-text:visible').text())
      .show();
    $NS.find('.js-gift-message-text').hide();
    e.preventDefault();
  });

  $(document).on('keydown', '#step1', function (e) {
    if (e.keyCode == 13) { // Enter - next step, instead of submit form
      $(this).find('.js-next-step:first-child').trigger('click'); //.click();
      e.preventDefault();
    }
  });

  // Scroll to correction section after submitting bad data.
  if (!$('body#gifts_create').length) { return; }

  if ($('#step1 .field_with_errors > #donor_subscriber_attributes_name').length) {
    // no-op
  } else if ($('#step1 .field_with_errors > #donor_subscriber_attributes_email').length) {
    transition_name_to_email();
  } else if ($('#step3 .field_with_errors')) {
    scroll_to_div($("#step3"), $("#step1"));

    // Find the correct gift message text and show it
    $NS.find('.js-gift-message-text[data-giving-length="' + $('.js-giving-length').val() + '"]').show();
  }

});

