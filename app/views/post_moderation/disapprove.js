$("#c-posts a#approve").hide();
$("#c-posts a#disapprove").hide();
$("#c-posts a#unapprove").hide();

$("#c-post-moderation #post-<%= @post.id %>").hide();
