/* eslint no-console:0 */
function importAll(r) {
  r.keys().forEach(r);
}

// This will only import the necessary polyfills needed by the current browserslist setting in package.json, not
// everything. See @babel/preset-env.
import "core-js";

require('hammerjs');
require('jquery-hotkeys');
import Alpine from 'alpinejs';
import morph from '@alpinejs/morph';
import persist from '@alpinejs/persist'

require.context("../../../public/images", true);

import jQuery from 'jquery';
require("jquery-ui/ui/widgets/autocomplete");
require("jquery-ui/ui/widgets/button");
require("jquery-ui/ui/widgets/dialog");

import Rails from '@rails/ujs';
Rails.start();

import 'tippy.js/dist/tippy.css';

importAll(require.context('../src/javascripts', true, /\.js(\.erb)?$/));
importAll(require.context('../src/styles', true, /\.s?css(?:\.erb)?$/));
importAll(require.context('../../components', true, /\.s?css(?:\.erb)?$/));

import Autocomplete from "../src/javascripts/autocomplete.js";
import ArtistCommentary from "../src/javascripts/artist_commentaries.js";
import Blacklist from "../src/javascripts/blacklists.js";
import CommentComponent from "../src/javascripts/comment_component.js";
import CommentVotesTooltipComponent from "../src/javascripts/comment_votes_tooltip_component.js";
import Cookie from "../src/javascripts/cookie.js";
import CurrentUser from "../src/javascripts/current_user.js";
import Device from "../src/javascripts/device.js";
import Draggable from "../src/javascripts/draggable.js";
import DTextEditor from "../src/javascripts/dtext_editor.js";
import FavoritesTooltipComponent from "../src/javascripts/favorites_tooltip_component.js";
import FileUploadComponent from "../src/javascripts/file_upload_component.js";
import ForumPostComponent from "../src/javascripts/forum_post_component.js";
import FormValidator from "../src/javascripts/form_validator.js";
import HelpTooltipComponent from "../src/javascripts/help_tooltip_component.js";
import IqdbQuery from "../src/javascripts/iqdb_queries.js";
import Note from "../src/javascripts/notes.js";
import Notice from "../src/javascripts/notice.js";
import MediaAssetComponent from "../src/javascripts/media_asset_component.js";
import PopupMenuComponent from "../src/javascripts/popup_menu_component.js";
import Post from "../src/javascripts/posts.js";
import PostModeMenu from "../src/javascripts/post_mode_menu.js";
import PostTooltip from "../src/javascripts/post_tooltips.js";
import PostVotesTooltipComponent from "../src/javascripts/post_votes_tooltip_component.js";
import PreviewSizeMenuComponent from "../src/javascripts/preview_size_menu_component.js";
import RelatedTag from "../src/javascripts/related_tag.js";
import Shortcuts from "../src/javascripts/shortcuts.js";
import TagCounter from "../src/javascripts/tag_counter.js";
import TimeSeriesComponent from "../src/javascripts/time_series_component.js";
import Upload from "../src/javascripts/uploads.js";
import UserTooltip from "../src/javascripts/user_tooltips.js";
import Utility from "../src/javascripts/utility.js";
import Ugoira from "../src/javascripts/ugoira.js";

let Danbooru = {};
Danbooru.Autocomplete = Autocomplete;
Danbooru.ArtistCommentary = ArtistCommentary;
Danbooru.Blacklist = Blacklist;
Danbooru.CommentComponent = CommentComponent;
Danbooru.CommentVotesTooltipComponent = CommentVotesTooltipComponent;
Danbooru.Cookie = Cookie;
Danbooru.CurrentUser = CurrentUser;
Danbooru.Device = Device;
Danbooru.Draggable = Draggable;
Danbooru.DTextEditor = DTextEditor;
Danbooru.FavoritesTooltipComponent = FavoritesTooltipComponent;
Danbooru.FileUploadComponent = FileUploadComponent;
Danbooru.ForumPostComponent = ForumPostComponent;
Danbooru.FormValidator = FormValidator;
Danbooru.HelpTooltipComponent = HelpTooltipComponent;
Danbooru.IqdbQuery = IqdbQuery;
Danbooru.MediaAssetComponent = MediaAssetComponent;
Danbooru.Note = Note;
Danbooru.Notice = Notice;
Danbooru.PopupMenuComponent = PopupMenuComponent;
Danbooru.Post = Post;
Danbooru.PostModeMenu = PostModeMenu;
Danbooru.PostTooltip = PostTooltip;
Danbooru.PostVotesTooltipComponent = PostVotesTooltipComponent;
Danbooru.PreviewSizeMenuComponent = PreviewSizeMenuComponent;
Danbooru.RelatedTag = RelatedTag;
Danbooru.Shortcuts = Shortcuts;
Danbooru.TagCounter = TagCounter;
Danbooru.TimeSeriesComponent = TimeSeriesComponent;
Danbooru.Upload = Upload;
Danbooru.UserTooltip = UserTooltip;
Danbooru.Utility = Utility;
Danbooru.Ugoira = Ugoira;

// Aliases for backwards compatibility with userscripts.
Utility.notice = Notice.info;
Utility.error = Notice.error;
Danbooru.notice = Notice.info;
Danbooru.error = Notice.error;

window.$ = jQuery;
window.jQuery = jQuery;
window.Alpine = Alpine;
window.Danbooru = Danbooru;

Alpine.plugin(morph);
Alpine.plugin(persist)

$(document).on("alpine:initialized", () => Alpine._initialized = true);
$(() => Alpine.start());
