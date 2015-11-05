$(function () {
  $('.js-modal-overlay-open').on('click', function (e) {

    var $modal = $('body').find($(this).attr('href'));

    $modal.fadeIn();
    $modal.css({
      'height': $(window).height(),
      'top': $(window).scrollTop() + 20
    });


    if ($($(this).attr('href')).find('.js-focus-on-open').length && $(window).width() > 568) {
      $('.modal-overlay').find('.js-focus-on-open').focus();
    }

    e.preventDefault();
  });

  $('.js-modal-overlay-close').on('click', function (e) {

    $(this).closest('.modal-overlay').fadeOut();

    $('body,html').css({
      'overflow': 'visible'
    });

    e.preventDefault();
  });

  $(document).click(function(event) {
    if (!$(event.target).closest(".modal-overlay .js-interior").length) {
      $(event.target).closest('.modal-overlay').fadeOut();
    }
  });

  $(document).on('keydown', function (e) {
    if (e.keyCode == 27) {
       $('.modal-overlay').fadeOut();
    }
  });
});
