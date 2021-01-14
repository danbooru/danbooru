## Unreleased

### Changes

* The next/previous post navbar is now available to logged out users. This is
  the navbar beneath posts that lets you move to the next or previous post in a
  tag search. Previously this was only available to logged-in users.

* Removed the option to disable the next/previous post navbar.

* Removed the option to disable keyboard shortcuts.

## 2021-01-12

### Changes

* Using the Enter key to submit an upload or save a tag edit will be removed
  in the future. Ctrl+Enter should be used instead (issue #4661).

* Added a new Restricted user level. New users start out as Restricted if they
  signup from a proxy or are detected as a sockpuppet. Being restricted is like
  a soft ban: you can't upload, edit tags, create comments or forum posts, or
  otherwise make any changes to the site, but you can still keep favorites,
  saved searches, and other personal things. Restricted users must verify
  their email address to become unrestricted.

* The Restricted system actually existed before, the only change is that now
  it's a public user level instead of a hidden flag on someone's account.

* Your IP address, location, and browser version are now recorded when you
  login to your account. They're also recorded when you create an account, or
  do any sensitive account actions, such as changing your password or email
  address, requesting a password reset, or deleting your account. Failed login
  attempts to your account are also recorded. Mods will be able to view this
  information. This information is recorded for account security purposes and
  for site moderation purposes (detecting sockpuppet accounts and ban evasion).

### Fixes

* Fixed a bug with not being able to upload certain Hentai Foundry posts (issue #4657).
* Fixed a bug with tag scripts sometimes adding the [[null]] tag (issue #4663).
* Fixed various issues with wiki other names, artist other names, and saved
  search labels allowing invalid characters.
* Fixed slow autocomplete when searching for Japanese or other non-English text.

### API Changes

* As described above, there's a new Restricted user level. Anything dealing
  with users will need to deal with a new user level.

* Added support for the following types of searches:

  * `<field>_not` searches on enum fields:
    * <https://danbooru.donmai.us/mod_actions?search[category_not]=post_regenerate,post_regenerate_iqdb>
    * <https://danbooru.donmai.us/mod_actions?search[category_id_not]=40..50>
    * etc

  * `<field>_<eq|not_eq|lt|gt|lteq|gteq>` searches on foreign key fields (user IDs, post IDs, etc):
    * <https://danbooru.donmai.us/comments?search[post_id_lt]=100000&group_by=comment>
    * <https://danbooru.donmai.us/comments?search[creator_id_not_eq]=502584&group_by=comment>
    * etc

  * `any_<field>_matches_regex`, where <field> is an array field:
    * <https://danbooru.donmai.us/wiki_pages?search[any_other_name_matches_regex]=^blah>
    * <https://danbooru.donmai.us/artists?search[any_other_name_matches_regex]=^blah>

  * Using multiple search filters on the same field. Before things like this didn't work:
    * <https://danbooru.donmai.us/tags?search[post_count_gt]=100&search[post_count_lt]=200>
    * <https://danbooru.donmai.us/comments?search[post][rating]=s&search[post_tags_match]=touhou>

# Past releases

* <https://github.com/danbooru/danbooru/tags>
* <https://danbooru.donmai.us/forum_posts?search[creator_name]=evazion&search[topic][title]=Danbooru+2+Issues+Topic>
