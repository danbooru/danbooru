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
