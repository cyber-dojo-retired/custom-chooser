/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = (function(cd, $) {

  cd.homePageUrl = () => {
    return '/dojo/index/';
  };

  cd.switchEntry = (previous, current) => {
    if (previous !== undefined) {
      $(previous).removeClass('selected');
    }
    $(current).addClass('selected');
  };

  return cd;

})(cyberDojo || {}, jQuery);
