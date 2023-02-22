# Rottweiler

[![Maintainability](https://api.codeclimate.com/v1/badges/abc07c78d5a9ece0340a/maintainability)](https://codeclimate.com/github/demetra-it/rottweiler/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/abc07c78d5a9ece0340a/test_coverage)](https://codeclimate.com/github/demetra-it/rottweiler/test_coverage)
[![CI Test](https://github.com/demetra-it/rottweiler/actions/workflows/ci-test.yml/badge.svg)](https://github.com/demetra-it/rottweiler/actions/workflows/ci-test.yml)
[![Gem Version](https://badge.fury.io/rb/rottweiler.svg)](https://badge.fury.io/rb/rottweiler)

Rottweiler is a Ruby gem that provides functionality for verifying JSON Web Tokens (JWTs).
It allows you to easily verify the authenticity and integrity of JWTs, making it an essential tool for applications
that rely on JWT-based authentication and authorization.
Rottweiler's intuitive interface and comprehensive documentation make it easy to use and integrate into new or existing Rails projects.

## Requirements

- Ruby >= 2.7
- Rails >= 5.x

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add rottweiler

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install rottweiler

## Configuration

Before start using Rottweiler gem you might need to configure it to fit your application. First of all you need to choose the appropriate
cryptographic algorithm which is used for JWT generation and verification. The most common are HMAC and RSA, but there're also other available
algorithms. You can find more about available algorithms in the documentation of [JWT gem](https://github.com/jwt/ruby-jwt).

To configure Rottwiler gem you should add a new initializer file to `config/initializers/rottweiler.rb` and set `Rottweiler.config` to configure it for your application.

Below you can find an example of how to configure Rottweiler for verification of JWTs using the RSA algorithm:

```ruby
# frozen_string_literal: true

require 'rottweiler'

Rottweiler.config do |config|
  # Here an example of configuration for JWT generated with RSA algorithm (RSA 256)
  config.jwt.algorithm = 'RS256'
  # Decode key must be a OpenSSL::PKey::RSA when RSA algorithm is used
  config.jwt.decode_key = OpenSSL::PKey::RSA.new(ENV['JWT_PUBLIC_KEY'])
end
```

### JWT header and param

By default Rottweiler will look for JWT token in `headers['Authorization']` header and `params[:token]`, but if you need to use a different header or param, you can specify which header and parameter to use for JWT lookup:

```ruby
Rottweiler.config do |config|
  config.token_header = 'X-JWT-Token'

  # To search for JWT token in `params[:_jwt]`
  config.token_param = [:_jwt]

  # To search for JWT token in `params[:secrets][:jwt]`
  config.token_param = [:secrets, :jwt]
end
```

### Unauthorized status code

If for some reason you don't want Rottweiler to respond with `401 Unauthorized` on authentication failure, you can customize the status code by setting:

```ruby
Rottweiler.config.unauthorized_status = :bad_request

# or

Rottweiler.config do |config|
  config.unauthorized_status = 403
end
```

## Usage

To start using Rottweiler in your controllers you just need to include `Rottweiler::Authentication` module in your controllers:

```ruby
class ApplicationController < ActionController::API
  include Rottweiler::Authentication

  # If you want to run some specific code on authentication failure, you can do it
  # by setting on_authentication_failed callback
  on_authentication_failed do |errors|
    # your code here
  end

  # If you need to run some specific code on authentication success, you can do it
  # by setting on_authentication_success callback
  on_authentication_success do |data|
    # your code here
  end
end
```

### Skip authentication

Sometimes you might want to skip authentication for specific controllers or actions. For doing so you can use `skip_authentication!` helper inside your controller:

```ruby
class PublicController < ApplicationController
  # Skip authentication for all the actions in this controller (make it public).
  skip_authentication!
end
```

If you want to skip authentication only for specific actions, you can pass the name of the actions for which you want to skip authentication with `:only` option:

```ruby
class CustomController < ApplicationController
  skip_authentication! only: %i[status public_action]

  # Authentication required
  def index; end

  # Skip authentication
  def status; end

  # Skip authentication
  def public_action; end
end
```

You can also proceed in an opposite direction, by skipping authentication for all the actions except the actions specified with `:except` option:

```ruby
class StrangeController < ApplicationController
  skip_authentication! except: %i[private_action]

  # Skip authentication
  def index; end

  # Authentication required
  def private_action; end
end
```

**NOTE**: `Rottweiler::Authentication` have to be included before other authorization modules, in order to perform authentication checks before authorization.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/demetra-it/rottweiler. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/rottweiler/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rottweiler project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rottweiler/blob/master/CODE_OF_CONDUCT.md).
