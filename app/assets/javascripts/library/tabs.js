$(function() {
  $('.js-scroll--h').each(function(i, el) { 
    new FTScroller(el, {
      scrollingY: false,
      scrollbars: false,
      bouncing: false,
      updateOnWindowResize: true
    });
  });
});