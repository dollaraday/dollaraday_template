$(function () {

  var $NS = $('body#nonprofits_show');

  if (!$NS.length) {
    return;
  }

  $(document).on('keydown', function (e) {
    if (e.keyCode == 37) {
       $NS.find('.prev')[0].click();
    }
    if (e.keyCode === 39) {
       $NS.find('.next')[0].click();
    }
  });

});
