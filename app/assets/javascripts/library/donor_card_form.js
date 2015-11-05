$(function () {
  $('#donor_card_attributes_card_number').payment('formatCardNumber');

  // Do our best to reformat the number on page load by triggering reFormatCarNumber
  // thru the paste event -- if it's a valid card type then the formatting should work
  $('#donor_card_attributes_card_number').trigger('paste');
});
