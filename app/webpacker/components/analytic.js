if (ENV.ENV == "production") {
  window._paq = window._paq || [];

  const url = 'https://stats.data.gouv.fr/';
  const trackerUrl = `${url}piwik.php`;
  const jsUrl = `${url}piwik.js`;

  // Configure Matomo analytics
  window._paq.push(['setDoNotTrack', true]);
  window._paq.push(['enableLinkTracking']);

  // Load script from Matomo
  window._paq.push(['setTrackerUrl', trackerUrl]);
  window._paq.push(['setSiteId', ENV.MATOMO_APP_ID]);

  const script = document.createElement('script');
  const firstScript = document.getElementsByTagName('script')[0];
  script.type = 'text/javascript';
  script.id = 'matomo-js';
  script.async = true;
  script.src = jsUrl;
  firstScript.parentNode.insertBefore(script, firstScript);

  $(document).on('shown.bs.modal', '.modal', sendDataToMatomo);
  $(document).on('turbolinks:load', sendDataToMatomo);
}

// see https://developer.matomo.org/guides/spa-tracking
function sendDataToMatomo (event) {
  if (event.data && event.data.timing) {
    let loadTimeMs = event.data.timing.visitEnd - event.data.timing.visitStart;
    window._paq.push(['setGenerationTimeMs', loadTimeMs]);
  }
  if (window.gMatomoPreviousPageUrl !== undefined) {
    window._paq.push(['setReferrerUrl', window.gMatomoPreviousPageUrl]);
  }
  window._paq.push(['setCustomUrl', window.location.href]);
  window._paq.push(['setDocumentTitle', document.title]);
  window._paq.push(['trackPageView']);

  window.gMatomoPreviousPageUrl = window.location.href;
}
