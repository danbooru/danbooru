# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

if File.exists?(File.expand_path("~/.danbooru/secret_token"))
  Danbooru::Application.config.secret_token = File.read(File.expand_path("~/.danbooru/secret_token"))
else
  Danbooru::Application.config.secret_token = SecureRandom.hex(64)
end

