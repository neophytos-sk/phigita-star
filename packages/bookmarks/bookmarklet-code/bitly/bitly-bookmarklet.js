_load = function(u) {
var e = document.createElement('script');
e.setAttribute('language','javascript');
e.setAttribute('type', 'text/javascript');
e.setAttribute('src',u); document.body.appendChild(e);
};
_loadCss = function(u) {
var e = document.createElement('link');
e.setAttribute('type', 'text/css');
e.setAttribute('href', u);
e.setAttribute('rel', 'stylesheet');
e.setAttribute('media', 'screen');
try {
document.getElementsByTagName('head')[0].appendChild(e);
} catch(z) {
document.body.appendChild(e);
}
};
_loadCss('http://bit.ly/s/v131/css/bitly_sidebar.css');

var _bitly_long_url = document.location.href;
if (_bitly_long_url.indexOf("#") == -1 && document.location.hash ) {
_bitly_long_url = _bitly_long_url + document.location.hash;
}
_load('http://bit.ly/bookmarklet/sidebar.js?v=131&u='+encodeURIComponent(_bitly_long_url) );
