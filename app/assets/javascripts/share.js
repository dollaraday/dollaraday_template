
// http://stackoverflow.com/questions/14715535/mobile-safari-page-unload-hide-blur-for-deep-linking/14751543#14751543
// http://stackoverflow.com/questions/1108693/is-it-possible-to-register-a-httpdomain-based-url-scheme-for-iphone-apps-like/1109200#1109200

var mobile = /android|avantgo|blackberry|blazer|compal|elaine|fennec|hiptop|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile|o2|opera mini|palm( os)?|plucker|pocket|pre\/|psp|smartphone|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce; (iemobile|ppc)|xiino/i;
var iphone = /ip(hone|od)/i;

var now = new Date().valueOf();
var link = window.location.href;
var url = document.getElementById('url').innerHTML;

if(!url)
  url = window.location.hostname;

var clicked = +new Date;
var timeout = 100;

if(iphone.test(navigator.userAgent)) {

    if(!!~link.indexOf("facebook.com")){
      console.log('facebook:link', url);

      // TODO FIX ME | var facebook_app_url = "fb://publish/?text=some text to post"
      facebook_app_url = unescape(link.split('url=')[1])
      facebook_app_url = facebook_app_url.replace(/amp;/g,'')

      window.location = facebook_app_url;
    }
    if(!!~link.indexOf("twitter.com")){
      console.log('twitter:link', url);

      var message = decodeURIComponent(url.split('text=')[1]);

      message = message.replace(/amp;|&/g,'').replace(/\+/g,' ');
      message = message.split('url=')[0];
      var twitter_app_url = "twitter://post?message=" + message;

      window.location = twitter_app_url;
    }

    !window.document.webkitHidden && setTimeout(function () {
        setTimeout(function () {
            window.location = url;
        }, 100);
    }, 500);
}
else{
    console.log('desktop:url', url)

    if(!!~link.indexOf("facebook.com")){
      // UGLY
			var facebook_app_url = unescape(link.split('url=')[1])
			facebook_app_url = facebook_app_url.replace(/amp;/g,'')

      console.log(facebook_app_url, 'fb:url')
      window.location = facebook_app_url;

    }
    if(!!~link.indexOf("twitter.com")){
      window.location = url;
    }


}


