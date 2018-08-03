/* eslint no-console:0 */

function importAll (r) {
  r.keys().forEach(r);
}

require('jquery-ujs');
require('hammerjs');

// should start looking for nodejs replacements
importAll(require.context('../vendor', true, /\.js$/));

importAll(require.context('../src/styles/base', true, /\.scss$/));

require("jquery-ui/ui/widgets/autocomplete");
require("jquery-ui/ui/widgets/button");
require("jquery-ui/ui/widgets/dialog");
require("jquery-ui/ui/widgets/draggable");
require("jquery-ui/ui/widgets/resizable");
require("jquery-ui/themes/base/core.css");
require("jquery-ui/themes/base/autocomplete.css");
require("jquery-ui/themes/base/button.css");
require("jquery-ui/themes/base/dialog.css");
require("jquery-ui/themes/base/draggable.css");
require("jquery-ui/themes/base/resizable.css");
require("jquery-ui/themes/base/theme.css");

importAll(require.context('../src/javascripts', true, /\.js(\.erb)?$/));
importAll(require.context('../src/styles/common', true, /\.scss(?:\.erb)?$/));
importAll(require.context('../src/styles/specific', true, /\.scss(?:\.erb)?$/));

export { default as ArtistCommentary } from "../src/javascripts/artist_commentaries.js";
export { default as Artist } from "../src/javascripts/artists.js";
export { default as Autocomplete } from "../src/javascripts/autocomplete.js.erb";
export { default as Blacklist } from "../src/javascripts/blacklists.js";
export { default as Comment } from "../src/javascripts/comments.js";
// export { default as Common } from "../src/javascripts/common.js";
export { default as Cookie } from "../src/javascripts/cookie.js";
export { default as Dtext } from "../src/javascripts/dtext.js";
export { default as FavoriteGroup } from "../src/javascripts/favorite_groups.js";
export { default as Favorite } from "../src/javascripts/favorites.js";
export { default as ForumPost } from "../src/javascripts/forum_posts.js";
export { default as JanitorTrials } from "../src/javascripts/janitor_trials.js";
export { default as ModQueue } from "../src/javascripts/mod_queue.js";
export { default as NewsUpdate } from "../src/javascripts/news_updates.js";
export { default as Note } from "../src/javascripts/notes.js";
export { default as Paginator } from "../src/javascripts/paginator.js";
export { default as Pool } from "../src/javascripts/pools.js";
export { default as PostAppeal } from "../src/javascripts/post_appeals.js";
export { default as PostFlag } from "../src/javascripts/post_flags.js";
export { default as PostModeMenu } from "../src/javascripts/post_mode_menu.js";
export { default as PostModeration } from "../src/javascripts/post_moderation.js";
export { default as PostPopular } from "../src/javascripts/post_popular.js";
export { default as PostTooltip } from "../src/javascripts/post_tooltips.js.erb";
export { default as Post } from "../src/javascripts/posts.js.erb";
export { default as RelatedTag } from "../src/javascripts/related_tag.js.erb";
// export { default as Responsive } from "../src/javascripts/responsive.js";
export { default as SavedSearch } from "../src/javascripts/saved_searches.js";
export { default as Shortcuts } from "../src/javascripts/shortcuts.js";
export { default as TagScript } from "../src/javascripts/tag_script.js";
export { default as Upload } from "../src/javascripts/uploads.js";
export { default as Utility } from "../src/javascripts/utility.js";
export { default as WikiPage } from "../src/javascripts/wiki_pages.js";
