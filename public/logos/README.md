# Logos

This directory contains logo images for external sites (e.g. Pixiv, Twitter, etc). These are displayed as icons next to
artist profile links throughout Danbooru.

To add a logo for a new site, add a file named `<site-name>-logo.png`, where `<site-name>` is the lowercase site name
with spaces and special characters replaced by hyphens (e.g. `Anime News Network` becomes `anime-news-network-logo.png`).

The site name is derived automatically from the website's URL, so that e.g. `https://www.pixiv.net` becomes `Pixiv`,
which matches `pixiv-logo.png`. If the site name doesn't match the logo filename automatically, update `site_name` in
[app/logical/source/url/null.rb](../../app/logical/source/url/null.rb) to match.

Logos should have a transparent background, and should be legible over both a light and dark background.

`external_site_icon` in [app/helpers/icon_helper.rb](../../app/helpers/icon_helper.rb) is the method used to display these icons.

# See also

* `site_name` in [app/logical/source/url/null.rb](../../app/logical/source/url/null.rb) (where custom site names for miscellaneous sites are generated)
* `external_site_icon` in [app/helpers/icon_helper.rb](../../app/helpers/icon_helper.rb)
* http://localhost:3000/static/components (visual list of all site logos)
