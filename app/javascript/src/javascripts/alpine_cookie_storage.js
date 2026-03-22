import Cookie from "./cookie";

// Used with `Alpine.$persist(..).using(AlpineCookieStorage)` to clear cookies if they contain invalid JSON. This is to work around
// a bug where $persist raises JSON.parse errors if a value is set to `undefined` or if a cookie is manually set to invalid JSON.
export default class AlpineCookieStorage {
  static getItem(key) {
    try {
      const raw = Cookie.getItem(key);

      JSON.parse(raw); // Just validate then return the raw value because $persist does its own parsing
      return raw;
    } catch (err) {
      this.removeItem(key);
      return null; // Causes $persist to fall back to the setting's default value
    }
  }

  static setItem(key, value) {
    Cookie.setItem(key, value ?? null); // Convert undefined to null
  }

  static removeItem(key) {
    Cookie.removeItem(key);
  }
}
