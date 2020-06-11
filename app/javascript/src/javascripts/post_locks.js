let PostLock = {};

PostLock.initialize_all = function() {
  if ($("#c-post-locks #a-new").length) {
    $(document).on("click.danbooru", ".select-locks", PostLock.modify_locks);
  }
}

PostLock.modify_locks = function(e) {
  let lock_types = $(e.target).closest(".lock-group").data("types");
  let operation = $(e.target).data("operation");
  $(".list-of-post-locks input.boolean").each((i, input)=>{
    let type = $(input).data("type");
    if (lock_types.includes(type)) {
      switch (operation) {
      case "on":
        input.checked = true;
        break;
      case "off":
        input.checked = false;
        break;
      case "invert":
        input.checked = !input.checked;
        break;
      default:
      }
    }
  });
  e.preventDefault();
}

$(document).ready(function() {
  PostLock.initialize_all();
});

export default PostLock
