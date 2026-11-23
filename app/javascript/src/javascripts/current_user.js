import Alpine from "@alpinejs/csp";

export default class CurrentUser {
  static data(key) {
    return $("body").data(`current-user-${key}`);
  }

  static update(settings) {
    return $.ajax(`/users/${CurrentUser.data("id")}.json`, {
      method: "PUT",
      data: { user: settings }
    });
  }

  static set theme(theme) {
    let autoTheme = matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    document.body.dataset.currentUserTheme = theme === 'auto' ? autoTheme : theme;
  }

  static darkMode() {
    return getComputedStyle(document.body).getPropertyValue("--theme-background").trim() === "dark";
  }
}

// The theme setting on the settings page. Switches the page to the selected theme before the settings are saved.
Alpine.data("themePicker", () => ({
  preview(theme) {
    CurrentUser.theme = theme;
  },
}));
