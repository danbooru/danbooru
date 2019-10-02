let CurrentUser = {};

CurrentUser.data = function(key) {
  return $("body").data(`user-${key}`);
};

CurrentUser.update = function(settings) {
  return $.ajax(`/users/${CurrentUser.data("id")}.json`, {
    method: "PUT",
    data: { user: settings }
  });
};

export default CurrentUser;
