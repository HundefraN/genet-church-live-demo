// web/flutter_bootstrap.js

window.addEventListener('load', function(ev) {
  var loadingText = document.getElementById("loading-text");

  _flutter.loader.loadEntrypoint({
    onProgress: function(event) {
      if (event.total) {
        var percent = Math.round(event.loaded / event.total * 100);
        loadingText.innerText = "Downloading (" + percent + "%)...";
      } else {
        loadingText.innerText = "Downloading...";
      }
    },
    onEntrypointLoaded: function(engineInitializer) {
      loadingText.innerText = "Initializing App...";
      engineInitializer.initializeEngine({
        // THIS IS THE CRITICAL LINE
        renderer: "html"
      }).then(function(appRunner) {
        loadingText.innerText = "Running App...";
        appRunner.runApp();
      });
    }
  });
});

function hideLoadingIndicator() {
  var loadingContainer = document.getElementById("loading-container");
  if (loadingContainer) {
    loadingContainer.style.opacity = '0';
    setTimeout(() => { loadingContainer.remove(); }, 500);
  }
}