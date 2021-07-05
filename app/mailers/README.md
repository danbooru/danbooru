# Mailers

This directory contains mailers for sending emails. Mailers are kind of like controllers, except for generating emails
instead of generating HTML.

The actual email templates live in [app/views/user_mailer](../views/user_mailer).

Emails are sent asynchronously using a background job. If sending the email fails, it will be retried later.

Sending emails requires a SMTP server to be configured in
[config/danbooru_local_config.rb](../../config/danbooru_local_config.rb). In production,
[Amazon SES](https://aws.amazon.com/ses/) is used to send emails.

Email templates can be previewed at http://localhost:3000/rails/mailers (assuming you're running `bin/rails server` on
port 3000, the default).

# Example

```ruby
UserMailer.welcome_user(@user).deliver_later
```

# See also

* [app/views/user_mailer](../views/user_mailer)
* [test/mailers/previews/user_mailer_preview.rb](../../test/mailers/previews/user_mailer_preview.rb)

# External links

* https://guides.rubyonrails.org/action_mailer_basics.html
* https://guides.rubyonrails.org/testing.html#testing-your-mailers