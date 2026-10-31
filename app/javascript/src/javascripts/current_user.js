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
  return getComputedStyle(document.body).getPropertyValue("--theme-background").trim() === "dark";
};

export default CurrentUser;
