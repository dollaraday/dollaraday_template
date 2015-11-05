$(function () {

  var $NS = $('body#site_index');

  if (!$NS.length) {
    return;
  }

  $('body').addClass('loaded');

  $('.js-hero-down').on('click', function (e) {
    $('html, body').animate({
      scrollTop: $('.js-learn-more-scroll-to').offset().top - 80
    }, 600, 'easeInOutExpo');
    e.preventDefault();
  });

  function resize_iphone () {
    var $iphone = $('.js-iphone-image'),
      $overlay = $('.js-iphone-overlay'),
      overlay_width = $iphone.width() - 42;

    $overlay.css({
      'top': 90,
      'width': overlay_width,
      'marginLeft': -(overlay_width/2)
    });

    $overlay.find('img').css({
      'left': -(($overlay.find('img').width() - overlay_width) / 2)
    });
  }

  $(window).resize(function() {
    resize_iphone();
  });

  $(window).load(function() {
    $NS.find('.js-iphone-overlay').removeClass('opacity-0');
    resize_iphone();
  });

});
