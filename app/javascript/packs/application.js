/* eslint no-console:0 */

function importAll(r) {
  r.keys().forEach(r);
}

require('@rails/ujs').start();
require('hammerjs');
require('jquery-hotkeys');

// should start looking for nodejs replacements
importAll(require.context('../vendor', true, /\.js$/));

require('jquery');
require("jquery-ui/ui/effects/effect-shake");
require("jquery-ui/ui/widgets/autocomplete");
require("jquery-ui/ui/widgets/button");
require("jquery-ui/ui/widgets/dialog");
require("jquery-ui/themes/base/core.css");
require("jquery-ui/themes/base/autocomplete.css");
require("jquery-ui/themes/base/button.css");
require("jquery-ui/themes/base/dialog.css");
require("jquery-ui/themes/base/theme.css");

require("@fortawesome/fontawesome-free/css/fontawesome.css");
require("@fortawesome/fontawesome-free/css/solid.css");
require("@fortawesome/fontawesome-free/css/regular.css");

importAll(require.context('../src/javascripts', true, /\.js(\.erb)?$/));
importAll(require.context('../src/styles', true, /\.s?css(?:\.erb)?$/));

export { default as jQuery } from "jquery";
export { default as Autocomplete } from '../src/javascripts/autocomplete.js.erb';
export { default as Blacklist } from '../src/javascripts/blacklists.js';
export { default as Comment } from '../src/javascripts/comments.js';
export { default as CurrentUser } from '../src/javascripts/current_user.js';
export { default as Dtext } from '../src/javascripts/dtext.js';
export { default as IqdbQuery } from '../src/javascripts/iqdb_queries.js';
export { default as Note } from '../src/javascripts/notes.js';
export { default as Post } from '../src/javascripts/posts.js.erb';
export { default as PostModeMenu } from '../src/javascripts/post_mode_menu.js';
export { default as PostTooltip } from '../src/javascripts/post_tooltips.js';
export { default as PostVersion } from '../src/javascripts/post_version.js';
export { default as RelatedTag } from '../src/javascripts/related_tag.js';
export { default as Shortcuts } from '../src/javascripts/shortcuts.js';
export { default as TagCounter } from '../src/javascripts/tag_counter.js';
export { default as Upload } from '../src/javascripts/uploads.js.erb';
export { default as UserTooltip } from '../src/javascripts/user_tooltips.js';
export { default as Utility } from '../src/javascripts/utility.js';
export { default as Ugoira } from '../src/javascripts/ugoira.js';
