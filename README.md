# Cloudflarer

A Ruby API client and library for [Cloudflare][].

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cloudflarer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cloudflarer

## Usage

For help with the command-line interface, just run

    cloudflarer --help

once the gem is installed.

The [API][] (v4) is documented by Cloudflare.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then,
run `rake test` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/bjjb/cloudflarer. This project is intended to be a
safe, welcoming space for collaboration, and contributors are expected to
adhere to the [Contributor Covenant](http://contributor-covenant.org) code of
conduct.


## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).

[Cloudflare]: https://cloudflare.com
[API]: https://api.cloudflare.com
