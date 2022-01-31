/* eslint no-console:0 */
function importAll(r) {
  r.keys().forEach(r);
}

// XXX for dropzone.
import "core-js/web/dom-collections";

require('@rails/ujs').start();
require('hammerjs');
require('jquery-hotkeys');

// should start looking for nodejs replacements
importAll(require.context('../vendor', true, /\.js$/));

import jQuery from 'jquery';
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
importAll(require.context('../../components', true, /\.js(\.erb)?$/));
importAll(require.context('../../components', true, /\.s?css(?:\.erb)?$/));

import Autocomplete from "../src/javascripts/autocomplete.js";
import Blacklist from "../src/javascripts/blacklists.js";
import CommentComponent from "../../components/comment_component/comment_component.js";
import CommentVotesTooltipComponent from "../../components/comment_votes_tooltip_component/comment_votes_tooltip_component.js";
import CurrentUser from "../src/javascripts/current_user.js";
import Dtext from "../src/javascripts/dtext.js";
import FavoritesTooltipComponent from "../../components/favorites_tooltip_component/favorites_tooltip_component.js";
import FileUploadComponent from "../../components/file_upload_component/file_upload_component.js";
import ForumPostComponent from "../../components/forum_post_component/forum_post_component.js";
import IqdbQuery from "../src/javascripts/iqdb_queries.js";
import Note from "../src/javascripts/notes.js";
import MediaAssetComponent from "../../components/media_asset_component/media_asset_component.js";
import PopupMenuComponent from "../../components/popup_menu_component/popup_menu_component.js";
import Post from "../src/javascripts/posts.js";
import PostModeMenu from "../src/javascripts/post_mode_menu.js";
import PostTooltip from "../src/javascripts/post_tooltips.js";
import PostVotesTooltipComponent from "../../components/post_votes_tooltip_component/post_votes_tooltip_component.js";
import RelatedTag from "../src/javascripts/related_tag.js";
import Shortcuts from "../src/javascripts/shortcuts.js";
import TagCounter from "../src/javascripts/tag_counter.js";
import Upload from "../src/javascripts/uploads.js";
import UserTooltip from "../src/javascripts/user_tooltips.js";
import Utility from "../src/javascripts/utility.js";
import Ugoira from "../src/javascripts/ugoira.js"
import NewRelic from "../src/javascripts/new_relic.js";

let Danbooru = {};
Danbooru.Autocomplete = Autocomplete;
Danbooru.Blacklist = Blacklist;
Danbooru.CommentComponent = CommentComponent;
Danbooru.CommentVotesTooltipComponent = CommentVotesTooltipComponent;
Danbooru.CurrentUser = CurrentUser;
Danbooru.Dtext = Dtext;
Danbooru.FavoritesTooltipComponent = FavoritesTooltipComponent;
Danbooru.FileUploadComponent = FileUploadComponent;
Danbooru.ForumPostComponent = ForumPostComponent;
Danbooru.IqdbQuery = IqdbQuery;
Danbooru.MediaAssetComponent = MediaAssetComponent;
Danbooru.Note = Note;
Danbooru.PopupMenuComponent = PopupMenuComponent;
Danbooru.Post = Post;
Danbooru.PostModeMenu = PostModeMenu;
Danbooru.PostTooltip = PostTooltip;
Danbooru.PostVotesTooltipComponent = PostVotesTooltipComponent;
Danbooru.RelatedTag = RelatedTag;
Danbooru.Shortcuts = Shortcuts;
Danbooru.TagCounter = TagCounter;
Danbooru.Upload = Upload;
Danbooru.UserTooltip = UserTooltip;
Danbooru.Utility = Utility;
Danbooru.Ugoira = Ugoira;
Danbooru.NewRelic = NewRelic;

Danbooru.notice = Utility.notice;
Danbooru.error = Utility.error;

window.$ = jQuery;
window.jQuery = jQuery;
window.Danbooru = Danbooru;
