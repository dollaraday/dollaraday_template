//= require_tree ./admin/donors
//= require_tree ./admin/subscribers


$(function() {
	// nonprofits#edit
  $('#nonprofit_name').keyup(throttle(function() {
		var $this = $(this),
			$slug = $('#nonprofit_slug'),
			slug = $this.val().toLowerCase().replace(/[^a-z0-9]/gi, '-').replace(/--/gi, '-').replace(/-+$/gi, '');
			$slug.val(slug);
  }, 500));

  $('#nonprofit_featured_on').keyup(throttle(function() {
    var $this = $(this),
      date = $this.val();

      date = date.split('/');
      date[0] = date[0].substring(0, 4);
      date[1] = date[1].substring(0, 2);
      date[2] = date[2].substring(0, 2);
      date = date.join('/');

      $this.val(date)
  }, 500))


  // AJAX request to get details about nonprofits -- helpful for admins
  $('#nonprofit_lookup_ein').click(function(e) {
    e.preventDefault();

    var ein = $('#nonprofit_ein').val();

    $.ajax({
      url: '/admin/nonprofits/lookup_ein.json',
      data: {ein: ein},
      success: function (data, status, xhr) {
        html = "";

        html += "<br /><b>Propublica Details for EIN " + ein + "</b>: <br />";
        html += "<p style='margin: 5px; padding: 20px; background: #FFF'>";
        html += JSON.stringify(data.propublica).replace(/,\"/gmi, ",<br />\"");
        html += "</p>";

        html += "<br /><b>NFG Details for EIN " + ein + "</b>: <br />";
        html += "<p style='margin: 5px; padding: 20px; background: #FFF'>";
        html += JSON.stringify(data.nfg).replace(/,\"/gmi, ",<br />\"");
        html += "</p>";

        $('#ein_lookup_data').html(html);
      }
    });
  });

});
