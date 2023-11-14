let CurrentUser = {};

CurrentUser.data = function(key) {
  return $("body").data(`current-user-${key}`);
};

CurrentUser.update = function(settings) {
  return $.ajax(`/users/${CurrentUser.data("id")}.json`, {
    method: "PUT",
    data: { user: settings }
  });
};

CurrentUser.darkMode = function() {
  let theme = CurrentUser.data("theme");

  return theme === "dark" || (theme === "auto" && window.matchMedia("(prefers-color-scheme: dark)").matches);
};

export default CurrentUser;
