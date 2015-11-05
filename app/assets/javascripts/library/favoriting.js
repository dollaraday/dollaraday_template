$(function() {

  /*
   * FAVORITING
   *
   * This powers the favorite toggle. The toggle actually contains an "Add to Favorites" and 
   * "Remove from Favorites" buttons (.js-favoriting-button), whose visibility is controlled
   * by the wrapper element (.js-favoriting) presence or lack of a .is-on class.
   *
   */

  // Animation for favoriting, a custom pulse effect
  $.Velocity.RegisterEffect("favoriting.enable", {
    defaultDuration: 250,
    calls: [
      [ { scaleX: 1.6, scaleY: 1.6 }, 0.5, { easing: "easeOutQuart" } ],
      [ { scaleX: 1,   scaleY: 1   }, 0.5, { easing: "easeOutQuart" } ]
    ]
  });

  // Plugin to toggle a favorite status (on the .js-favoriting wrapper element)
  $.fn.favoriteToggle = function(status) {
    if (status === true || status === false)
      this.toggleClass('is-on', status);
    else
      this.toggleClass('is-on');
    
    return this;
  };

  /*
   * This is the core of the favoriting behaviour.
   * — It assumes success, providing immediate feedback without waiting for the server.
   * — In the case of an error, undo the status change.
   *
   * The enabling animation toggles the status immediately, then animates with a bounce.
   * The disabling animation is actually no animation, just a simple status toggle.
   *
   */
  $('.js-favoriting').find('[data-remote="true"]')
    .on('ajax:beforeSend', function() {
      var $wrapper  = $(this).closest('.js-favoriting');
      var $button   = $(this).find('.js-favoriting-button').addBack('.js-favoriting-button').first();
      var action    = $button.data('favoriting-action');
      
      if (action == 'enable')
        $wrapper.favoriteToggle(true).find('.js-favoriting-button:visible').velocity('favoriting.enable');
      else if (action == 'disable')
        $wrapper.favoriteToggle(false);

    })
    .on('ajax:error', function() {
      var $button   = $(this).find('.js-favoriting-button').addBack('.js-favoriting-button').first();
      var action    = $button.data('favoriting-action');
      var $wrapper  = $(this).closest('.js-favoriting');

      if (action == 'enable')
        $wrapper.favoriteToggle(false);
      else if (action == 'disable')
        $wrapper.favoriteToggle(true);

      $wrapper.find('.js-favoriting-button:visible').velocity('callout.shake');
    });

  
  /*
   * Hover effects are done with JavaScript, not a :hover CSS selector.
   * 
   * In the event of an user removing a favorite, the button goes from colored to grayed out.
   * However, hovering over a grayed out button fades it to a colored one.
   * This means that removing a favorite would make the button gray, then back to colored (because
   * there are actually two different buttons), which would be confusing behaviour for users.
   * 
   * The solution is to only add a .hover class when the mouse enters *the wrapper* which contains
   * both buttons, so if the buttons are switched while the mouse is over them, it won't re-fire.
   * Removing the hover, however, is done when leaving both any of the icons AND their wrapper.
   * 
   */
  $('.js-favoriting')
    .mouseenter(function() { $(this).find('.js-favoriting-button:visible').addClass('hover'); })
    .mouseleave(function() { $(this).find('.js-favoriting-button.hover').removeClass('hover'); });
  $('.js-favoriting-button')
    .mouseleave(function() { $(this).removeClass('hover') });

});