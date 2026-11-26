import Alpine from "alpinejs";
import Cookie from "./cookie";

// Beta features are new features that users can turn on or off in the Beta tab of their settings. See app/logical/beta_feature.rb.
export default class BetaFeature {
  // @param name [String] The name of the feature, e.g. "new_feature".
  // @returns [Boolean] Whether the feature is on for this user. Always false on pages that use the blank layout.
  static enabled(name) {
    return (document.body.dataset.betaFeatures ?? "").split(" ").includes(name);
  }
}

// The toggles in the Beta tab of the settings page. Saves each toggle in the feature's cookie.
Alpine.data("betaFeatureToggles", () => ({
  toggle(input) {
    Cookie.put(input.dataset.cookieName, input.checked);
  },
}));
