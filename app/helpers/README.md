# Helpers

This directory contains helper functions used by views. Helpers are used for simple common functions, such as linking to
users or formatting timestamps.

Helper functions are globals. If you see an unnamespaced function in a view, and it's not a Rails function, then it's
probably a helper defined here.

All helper functions defined in this directory are globally available to all views. They're not limited to single views.
For example, the functions in [posts_helper.rb](posts_helper.rb) are available to all views, not just to
[app/views/posts](../views/posts).

The use of helper functions should be minimized. Partials or components are preferred for more complex widgets, or for
things used in only one or two places. Helper functions should be limited to very simple things used in nearly all
views.

# See also

* [app/views](../views)
* [app/components](../components)

# External links

* https://api.rubyonrails.org/classes/ActionController/Helpers.html
* https://www.rubyguides.com/2020/01/rails-helpers/