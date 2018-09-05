$(() => {
  $("#c-user-feedbacks #negative-policy").hide();
  $("#c-user-feedbacks #user_feedback_category").on("change.danbooru", (e) => {
    if (e.target.value === "negative") {
      $("#c-user-feedbacks #negative-policy").show();
    } else {
      $("#c-user-feedbacks #negative-policy").hide();
    }
  });
});
