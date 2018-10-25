/* eslint no-console:0 */
/* global require */

function importAll(r) {
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

export { default as Autocomplete } from '../src/javascripts/autocomplete.js.erb';
export { default as Blacklist } from '../src/javascripts/blacklists.js';
export { default as Comment } from '../src/javascripts/comments.js';
export { default as Dtext } from '../src/javascripts/dtext.js';
export { default as Note } from '../src/javascripts/notes.js';
export { default as Post } from '../src/javascripts/posts.js.erb';
export { default as PostModeMenu } from '../src/javascripts/post_mode_menu.js';
export { default as PostTooltip } from '../src/javascripts/post_tooltips.js';
export { default as RelatedTag } from '../src/javascripts/related_tag.js';
export { default as Shortcuts } from '../src/javascripts/shortcuts.js';
export { default as Upload } from '../src/javascripts/uploads.js';
export { default as Utility } from '../src/javascripts/utility.js';
export { default as Ugoira } from '../src/javascripts/ugoira.js';
export { mixpanelInit, mixpanelEvent, mixpanelAlias } from '../src/javascripts/mixpanel.js';
