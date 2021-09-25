class NewRelic {
  static initialize_all() {
    /* https://docs.newrelic.com/docs/browser/new-relic-browser/browser-agent-spa-api/setcustomattribute-browser-agent-api/ */
    if (typeof window.newrelic === "object") {
      window.newrelic.setCustomAttribute("screenWidth", window.screen.width);
      window.newrelic.setCustomAttribute("screenHeight", window.screen.height);
      window.newrelic.setCustomAttribute("screenResolution", `${window.screen.width}x${window.screen.height}`);
      window.newrelic.setCustomAttribute("devicePixelRatio", window.devicePixelRatio);
    }
  }
}

NewRelic.initialize_all();
export default NewRelic;
