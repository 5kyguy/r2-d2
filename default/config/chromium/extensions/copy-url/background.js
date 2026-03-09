chrome.browserAction.onClicked.addListener(function (tab) {
  var url = tab.url;
  chrome.tabs.executeScript(tab.id, {
    code:
      "var url = " +
      JSON.stringify(url) +
      "; navigator.clipboard.writeText(url).catch(function(){ var t=document.createElement('textarea'); t.value=url; document.body.appendChild(t); t.select(); document.execCommand('copy'); document.body.removeChild(t); });",
  });
});
