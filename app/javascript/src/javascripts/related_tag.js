import SourceDataComponent from "./source_data_component.js";
import { splitWords } from './utility';
import Alpine from 'alpinejs';

Alpine.store("relatedTags", {
  loading: false,
});

let RelatedTag = {};

RelatedTag.MAX_RELATED_TAGS = 25;

RelatedTag.initialize_all = function() {
  $(document).on("change.danbooru", ".related-tags input", RelatedTag.toggle_tag);
  $(document).on("click.danbooru", ".related-tags .tag-list a", RelatedTag.toggle_tag);
  $(document).on("input.danbooru.relatedTags", "#post_tag_string", RelatedTag.update_selected);
  $(document).on("click.danbooru.relatedTags", "#post_tag_string", RelatedTag.update_current_tag);

  $(document).on("danbooru:open-post-edit-dialog", RelatedTag.show);

  // Initialize the recent/favorite/translated/artist tag columns once, the first time the related tags are shown.
  $(document).one("danbooru:show-related-tags", RelatedTag.initialize_recent_and_favorite_tags);
  $(document).one("danbooru:show-related-tags", SourceDataComponent.fetchData);

  // Show the related tags automatically when the "Edit" tab is opened, or by default on the uploads page.
  $(document).on("danbooru:open-post-edit-tab", RelatedTag.show);
  if ($("#c-uploads #a-show #p-single-asset-upload").length) {
    RelatedTag.show();
  }
}

RelatedTag.initialize_recent_and_favorite_tags = function(event) {
  let media_asset_id = $("#related-tags-container").attr("data-media-asset-id");
  $.get("/related_tag.js", { user_tags: true, media_asset_id: media_asset_id });
}

RelatedTag.update_related_tags = async function(event) {
  if (event.button === 0 && !event.ctrlKey && !event.shiftKey && !event.metaKey && !event.altKey) {
    event.preventDefault();
    Alpine.store("relatedTags").loading = true;
    await $.get("/related_tag.js", { query: RelatedTag.current_tag().trim(), limit: RelatedTag.MAX_RELATED_TAGS });
    RelatedTag.show();
    Alpine.store("relatedTags").loading = false;
  }
}

RelatedTag.current_tag = function() {
  // 1. abc def |  -> def
  // 2. abc def|   -> def
  // 3. abc de|f   -> def
  // 4. abc |def   -> def
  // 5. abc| def   -> abc
  // 6. ab|c def   -> abc
  // 7. |abc def   -> abc
  // 8. | abc def  -> abc

  var $field = $("#post_tag_string");
  var string = $field.val();
  var n = string.length;
  var a = $field.prop('selectionStart');
  var b = $field.prop('selectionStart');

  if ((a > 0) && (a < (n - 1)) && (!/\s/.test(string[a])) && (/\s/.test(string[a - 1]))) {
    // 4 is the only case where we need to scan forward. in all other cases we
    // can drag a backwards, and then drag b forwards.

    while ((b < n) && (!/\s/.test(string[b]))) {
      b++;
    }
  } else if (string.search(/\S/) > b) { // case 8
    b = string.search(/\S/);
    while ((b < n) && (!/\s/.test(string[b]))) {
      b++;
    }
  } else {
    while ((a > 0) && ((/\s/.test(string[a])) || (string[a] === undefined))) {
      a--;
      b--;
    }

    while ((a > 0) && (!/\s/.test(string[a - 1]))) {
      a--;
      b--;
    }

    while ((b < (n - 1)) && (!/\s/.test(string[b]))) {
      b++;
    }
  }

  b++;
  return string.slice(a, b);
}

RelatedTag.update_current_tag = function() {
  let current_tag = RelatedTag.current_tag().trim();

  if (current_tag) {
    $(".general-related-tags-column").removeClass("hidden");
    $(".related-tags-current-tag").show().text(current_tag.replace(/_/g, " "));
    $(".related-tags-current-tag").attr("href", `/posts?tags=${encodeURIComponent(current_tag)}`);
  }
}

RelatedTag.update_selected = function(e) {
  var current_tags = RelatedTag.current_tags();

  $(".related-tags li").each((_, li) => {
    let tag_name = $(li).find("a").attr("data-tag-name");

    if (current_tags.includes(tag_name)) {
      $(li).addClass("selected");
      $(li).find("input").prop("checked", true);
    } else {
      $(li).removeClass("selected");
      $(li).find("input").prop("checked", false);
    }
  });

  RelatedTag.update_current_tag();
}

RelatedTag.current_tags = function() {
  let tagString = $("#post_tag_string").val().toLowerCase();
  return splitWords(tagString);
}

RelatedTag.toggle_tag = function(e) {
  var $field = $("#post_tag_string");
  var tag = $(e.target).closest("li").find("a").attr("data-tag-name");

  if (RelatedTag.current_tags().includes(tag)) {
    $field.val($field.val().replace(new RegExp(`(?<=^|\\s)${RegExp.escape(tag)}(?=$|\\s)`, "gi"), ""));
  } else {
    $field.val($field.val() + " " + tag);
  }
  $field.val($field.val().trim().replace(/ +/g, " ") + " ");

  RelatedTag.update_selected();

  // The timeout is needed on Chrome since it will clobber the field attribute otherwise
  setTimeout(function () { $field.prop('selectionStart', $field.val().length); }, 100);
  e.preventDefault();

  // Update the tag counter without triggering an input event.
  $field.trigger("danbooru:update-tag-counter");
}

RelatedTag.show = function(e) {
  $(document).trigger("danbooru:show-related-tags");
  e?.preventDefault();
}

$(function() {
  RelatedTag.initialize_all();
});

export default RelatedTag
