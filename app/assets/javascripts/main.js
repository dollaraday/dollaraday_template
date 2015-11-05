$(document).ready(function () {

  $('*[data-toggles]').on('click', function (e) {
    var $target = $("#"+$(this).data('toggles'));
    $(this).toggleClass('active');
    $target.toggle();
    e.preventDefault();
  });

  $('a.email_signup_link').click(function (e) {
    e.preventDefault();
    $(this).closest('.actions').find('.email_signup').toggleClass('hide');
  });
});