$(function () {

  var $NS = $('body#site_calendar');

  if (!$NS.length) {
    return;
  }

  // CALENDAR (ex-SELECTION CRITERIA)
  var $calendar_nav = $('#calendar_nav_links'),
    next_page = $calendar_nav.data('nextpage'),
    previous_page = $calendar_nav.data('previouspage'),
    path = location.pathname;

  if (previous_page.length) {
    $calendar_nav.append($('<a>Previous 30 days</a>').attr('class', 'button-outline button-green no-wrap mr1 ml1').attr('href', path + "?date=" + previous_page));
  }

  if (next_page.length) {
    $calendar_nav.append($('<a>Next 30 days</a>').attr('class', 'button-outline button-green no-wrap mr1 ml1').attr('href', path + "?date=" + next_page));
  }

  // This is kind of hacky but hides the intro once you start paginating
  if ($(location).attr('href').indexOf('week') >= 0) {
    $('body').scrollTop($('#nonprofits').position().top - $('.header-shim').outerHeight());
  }

  $('.js-read-more-link').on('click', function (e) {
    $(this).closest('.js-read-more').find('.js-read-more-show').show();
    $(this).closest('.js-read-more').find('.js-read-more-hide').hide();
    e.preventDefault();
  });

});
