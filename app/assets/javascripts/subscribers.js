$(function () {

  var $NS = $('#subscriber_show');

  if (!$NS.length) { return; }

  if ($NS.find('.field_with_errors').length) {
    $NS.find('.edit-field').trigger('click');
  }


  $('.js-form-link').on('click', function (e) {
    $('.js-form').hide();
    $('.js-form-link').fadeIn();

    $(this).fadeOut();

    var $form = $NS.find('#' + $(this).attr('data-form-id'));

    e.preventDefault();
    if ($form.find('.verification').length) {
      $form.fadeIn();
    } else {
      if (confirm("Are you sure?")) {
        $form.submit();
      }
    }
  });


  $('#change-billing-details-form').on('submit', function (e) {
    e.preventDefault();

    var $form = $(this),
      $error = $form.find('.error');

    $.ajax({
      url: $form.attr('action'),
      type: $form.attr('method'),
      data: $form.serialize(),
      beforeSend: function () {
        $error.text("");
      },
      success: function (data, status, xhr) {
        if (data.error) {
          $error.text(data.error);
        } else if (data.success) {
          console.log("data: ", data, status, xhr);
          // $form.replaceWith($("<p class=\"mt2\"><b>" + data.success + "</b></p>"));
        }
      },
      error: function (data, status, xhr, blah) {
      }
    });
  });


  $('#cancel-future-donations-form, #restart-future-donations-form').on('submit', function (e) {
    e.preventDefault();

    var $form = $(this),
      $error = $form.find('.error');

    $.ajax({
      url: $form.attr('action'),
      type: $form.attr('method'),
      data: $form.serialize(),
      beforeSend: function () {
        $error.text("");
      },
      success: function (data, status, xhr) {
        if (data.error) {
          $error.text(data.error);
        } else if (data.success) {
          $form.replaceWith($("<p class=\"mt2\"><b>" + data.success + "</b></p>"));
        }
      },
      error: function (data, status, xhr, blah) {
      }
    });
  });

});

