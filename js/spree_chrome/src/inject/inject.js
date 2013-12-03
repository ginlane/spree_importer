chrome.extension.sendMessage({}, function(response) {
	var readyStateCheckInterval = setInterval(function() {
	  if (document.readyState === "complete") {
		  clearInterval(readyStateCheckInterval);

      var url = window.location.search.split("?")[1].split("&"),
      http    = new XMLHttpRequest(),
      params  = { },
      pair    = undefined;

      for(var i=0,l=url.length;i<l;i++) {
        pair = url[i].split("=");
        params[pair[0]] = pair[1];
      }

      http.onreadystatechange = function() {
        if(http.readyState === 4 && /Authorization needed/.test(http.responseText)) {
          window.open(APP_URL + "?redir=" + window.location.href, "_blank");
        }
      };

      http.open("GET", APP_URL + "?spreadsheetId=" + params.key, true);
      http.send();
	  }
	}, 10);
});

APP_URL = "https://script.google.com/a/macros/ginlanemedia.com/s/AKfycbxHeOekt_MpyJ54riEniqP7icjqkdq9UKPCfGSIu8SHmkV4z6A/exec";
