$(function () {

  var NS = 'body#donors_index.admin';

  if ($(NS).length == 0) { return; }

  $(document).on('click', NS + ' .toggle-search', function () {
    $(NS).find('.search-form').toggle();
  });

});
