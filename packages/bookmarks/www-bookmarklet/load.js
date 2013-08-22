(function(){
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
 _loadCss('//www.phigita.net/bookmarklet/sidebar.css');


 var _reMark_long_url = document.location.href;
 if (_reMark_long_url.indexOf("#") == -1 && document.location.hash ) {
	 _reMark_long_url = _reMark_long_url + document.location.hash;
 }


 // _load('http://www.phigita.net/bookmarklet/sidebar.js?v=1&u='+encodeURIComponent(_reMark_long_url) );
 _load('//www.phigita.net/js/bookmarks.sidebar.js?v=2' );
})();
