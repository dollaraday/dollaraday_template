// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//

// ** Gems **
//= require jquery
//= require jquery.flot
//= require jquery.flot.resize
//= require jquery.flot.time

// ** Vendors **
//= require jquery_ujs
//= require jquery.cycle2.min
//= require jquery.easing.1.3
//= require jquery.payment
//= require jquery.tipsy
//= require mapbox
//= require skrollr.min
//= require ftscroller
//= require velocity
//= require velocity.ui

// ** Libraries **
//= require_directory ./library
//= require_directory ./library/modules

// ** Views **
//= require_directory ./donors
//= require_directory ./gifts
//= require main
//= require site
//= require nonprofits
//= require calendar
//= require subscribers


$(function() {

	if ($('.flash,.alert').length) {
		var flashHeight = $('.flash,.alert').outerHeight();
    setTimeout(function (){
      $('.flash,.alert').css({
        'marginTop': -flashHeight,
        'opacity': 0
      }, 500);
    }, 5000);
  }

  if ($('#stickybar').length) {
    $('body').addClass('stickybar-visible');
  }

  $('.select-box .title').on('click', function (e) {
    $(this).closest('.select-box').toggleClass('open');
    e.preventDefault();
  });

  $('.select-box .dropdown li').on('click', function () {
    $(this).closest('.select-box').toggleClass('open');
    $(this).closest('.select-box').find('.title .mr2').text($(this).text());
  });

  $(document).tipsy({
    gravity: 's',
    html: true,
    live: '.tooltip',
    fade: true,
    opacity: 1.0
  });

  $(document).tipsy({
    gravity: 'se',
    html: true,
    live: '.tooltip-se',
    fade: true,
    opacity: 1.0
  });


  var submitting_new_subscriber_form = false;

  $('form#new_subscriber').on('submit', function (e) {
    e.preventDefault();

    // Prevent accidental double submits
    if (submitting_new_subscriber_form) {
      return false;
    } else {
      submitting_new_subscriber_form = true;
    }

    var $form = $(this),
      $form_fields = $form.find('#form-fields'),
      $success = $('#form-success'),
      $error = $('#form-error'),
      $email_field = $('#subscriber_email');

    $.ajax({
      url: $form.attr('action'),
      type: $form.attr('method'),
      data: $form.serialize(),
      success: function (data, status, xhr) {
        $form_fields.remove();
        $error.hide();
        $success.show();
        $('#subscribers_popup .small_type').remove();
      },
      error: function (data, status, xhr, blah) {
        if (!$email_field.parent().is("div.field_with_errors")) {
          $email_field.wrap( "<div class='field_with_errors'></div>" );
        }
        $error.show().find('p').text(data.responseText);
      },
      complete: function () {
        submitting_new_subscriber_form = false;
      }
    });
  });

  $('a.facebook,a.twitter').on('click', function (e) {

    var myWindow = window.open($(this).attr('href'), $(this).text(), "width=500, height=400");

    e.preventDefault();
  });


  $(document).ready(function () {
    if (!/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
      var s = skrollr.init({forceHeight: false});
    }
  });

  // TODO DRY
  var $verify_donor_form = $('form.verify_donor_form'),
  $verify_donor_email = $verify_donor_form.find('input#donor_verification_email'),
  $verify_donor_message = $verify_donor_form.find('.message'),
  cached_email_lookups = {}; //  { 'a@a.com': false, 'b@b.com': "You're already ... "}

  var hash = window.location.hash.replace(/^#/, '');
  if (hash === 'manage') {
    $('#authenticate_link').click();
  }

  // TODO DRY
  $(document).on("ajax:beforeSend", "form.verify_donor_form", function (e, data, status, xhr) {
      var $form = $(this);
      $('.instructions', $form).css({color: 'black', fontWeight: 'bold', fontSize: '0.8em'}).text("Please wait...");
  });

  $(document).on("ajax:complete", "form.verify_donor_form", function (e, data, status, xhr) {

      var response = data.responseJSON,
      $form = $(this);

      if (response && response.success === true) {
          window.location = response.location;
      } else {
          $('.instructions', $form).css({color: 'red', fontWeight: 'bold', fontSize: '0.8em'}).text(response.message);
      }
  });

  $('.js-join-button').on('click', function (e) {
    $('.js-join-overlay').fadeIn();
    $('body,html').css({
      'overflow': 'hidden'
    });
    e.preventDefault();
  });

});
