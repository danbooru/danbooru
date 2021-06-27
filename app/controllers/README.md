# Controllers

Controllers are the entry points to Danbooru. Every URL on the site corresponds to a controller action. When a request
for an URL is made, the corresponding controller action is called to handle the request.

Controllers follow a convention where, for example, the URL <https://danbooru.donmai.us/posts/1234> is handled by the
`#show` method inside the `PostsController` living at [app/controllers/posts_controller.rb](posts_controller.rb).
<https://danbooru.donmai.us/posts?tags=touhou> is handled by the `#index` method in the PostsController. The HTML
template for the response lives at [app/views/posts/index.html.erb](../views/posts/index.html.erb). See below for more
examples.

Controllers are responsible for taking the URL parameters, checking whether the user is authorized to perform the
action, actually performing the action, then returning the response. Most controllers simply fetch or update a model,
then render an HTML template from [app/views](../views) in response.

# Example

A standard controller looks something like this:

```ruby
class BansController < ApplicationController
  def new
    @ban = authorize Ban.new(permitted_attributes(Ban))
    respond_with(@ban)
  end

  def edit
    @ban = authorize Ban.find(params[:id])
    respond_with(@ban)
  end

  def index
    @bans = authorize Ban.paginated_search(params, count_pages: true)
    respond_with(@bans)
  end

  def show
    @ban = authorize Ban.find(params[:id])
    respond_with(@ban)
  end

  def create
    @ban = authorize Ban.new(banner: CurrentUser.user, **permitted_attributes(Ban))
    @ban.save
    respond_with(@ban, location: bans_path)
  end

  def update
    @ban = authorize Ban.find(params[:id])
    @ban.update(permitted_attributes(@ban))
    respond_with(@ban)
  end

  def destroy
    @ban = authorize Ban.find(params[:id])
    @ban.destroy
    respond_with(@ban)
  end
end
```

# Routes

Each controller action above corresponds to an URL:

| Controller Action      | URL                                         | Route               | Route Helper        | View                          |
|------------------------|---------------------------------------------|---------------------|---------------------|-------------------------------|
| BansController#new     | https://danbooru.donmai.us/bans/new         | GET /bans/new       | new_ban_path        | app/views/bans/new.html.erb   |
| BansController#edit    | https://danbooru.donmai.us/bans/1234/edit   | GET /bans/:id/edit  | edit_ban_path(@ban) | app/views/bans/edit.html.erb  |
| BansController#index   | https://danbooru.donmai.us/bans             | GET /bans           | bans_path           | app/views/bans/index.html.erb |
| BansController#show    | https://danbooru.donmai.us/bans/1234        | GET /bans/:id       | ban_path(@ban)      | app/views/bans/show.html.erb  |
| BansController#create  | POST https://danbooru.donmai.us/bans        | POST /bans          |                     |                               |
| BansController#update  | PUT https://danbooru.donmai.us/bans/1234    | PUT /bans/:id       |                     |                               |
| BansController#destroy | DELETE https://danbooru.donmai.us/bans/1234 | DELETE /bans/:id    |                     |                               |

These routes are defined in [config/routes.rb](../../config/routes.rb).

# Authorization

Most permission checks for whether a user has permission to do something happen inside controllers, using `authorize`
calls.

The `authorize` method comes from the [Pundit](https://github.com/varvet/pundit) framework. This method checks whether
the current user is authorized to perform the current action. If not, it raises a `Pundit::NotAuthorizedError`, which is
caught in the `ApplicationController`.

The actual authorization logic for these calls lives in [app/policies](../policies). They follow a convention where the
authorization logic for the `BansController#create` action lives in `BanPolicy#create?`, which lives in
[app/policies/ban_policy.rb](../policies/ban_policy.rb). The call to `authorize` in the controller simply finds and
calls the ban policy.

The `#create`, `#new`, and `#update` actions also use `permitted_attributes` to check that the user is allowed to update
the model attributes they're trying to update. This also comes from the Pundit framework. See the
`permitted_attributes_for_create` and `permitted_attributes_for_update` methods in [app/policies](../policies).

# Responses

Controllers use `respond_with(@post)` to generate a response. This comes from the [Responders](https://github.com/heartcombo/responders)
gem. `respond_with` does the following:

* Detects whether the user wants an HTML, JSON, or XML response.
* Renders an HTML template from [app/views](../views) for HTML requests.
* Renders JSON or XML for API requests.
* Handles universal URL parameters, like `only` or `includes`.
* Handles universal behavior, like returning 200 OK for successful responses, or returning an error if trying
  to save a model with validation errors.

# HTML Responses

The HTML templates for controller actions live in [app/views](../views). For example, the template for
PostsController#show, which corresponds to https://danbooru.donmai.us/posts/1234, lives in
[app/views/posts/show.html.erb](../views/posts/show.html.erb).

Instance variables set by controllers are automatically inherited by views. For example, if a controller sets `@post`,
then the `@post` variable will be available in the view.

# API Responses

All URLs support JSON or XML responses. This is handled by `respond_with`.

The response format can be chosen in several ways. First, by adding a .json or .xml file extension:

* https://danbooru.donmai.us/posts.json
* https://danbooru.donmai.us/posts.xml

Second, by setting the `format` URL parameter:

* https://danbooru.donmai.us/posts?format=json
* https://danbooru.donmai.us/posts?format=xml

Third, by setting the `Accept` HTTP header:

```sh
curl -H "Accept: application/json" https://danbooru.donmai.us/posts
curl -H "Accept: application/xml" https://danbooru.donmai.us/posts
```

When generating API responses, `respond_with` uses the `api_attributes` method inside [app/policies](../policies) to
determine which attributes are visible to the current user.

# Application Controller

Global behavior that runs on every request lives inside the [ApplicationController](application_controller.rb). This
includes the following:

* Setting the current user based on their session cookies or API keys.
* Checking rate limits.
* Checking for IP bans.
* Adding certain HTTP headers.
* Handling exceptions.

# See also

* [app/models](../models)
* [app/policies](../policies)
* [app/views](../views)
* [config/routes.rb](../../config/routes.rb)
* [test/functional](../../test/functional)

# External links

* https://guides.rubyonrails.org/action_controller_overview.html
* https://github.com/heartcombo/responders
* https://github.com/varvet/pundit