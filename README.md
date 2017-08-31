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

### CLI

The executable has 3 top-level commands: `user` (for interaction with your
Cloudflare user account), `zones` (to list your zones) and `records`, which
list records in a specific zone. Note that you need to supply your Cloudflare
email address and password with every request, unless you set them in the
environment, as follows

    export CLOUDFLARE_EMAIL="bob@example.com"
    export CLOUDFLARE_PASSWORD="mysecretpa$$word"

So now you can, for example, get your user's ID:

    $ cloudflarer user
    1234567890abcdef1234567890abcdef

...or see the complete user information in JSON

    $ cloudflarer -f json user
    { "id":"1234567890abcdef1234567890abcdef", "email":"bob@example.com",
    "username":"bob",... }

...or in YAML

    $ cloudflarer -f yaml user
    ---
    id: 1234567890abcdef1234567890abcdef
    email: bob@example.com
    username: bob
    ...

...or in some custom format

    $ cloudflarer -f '{{username}} joined on {{created_on}}' user
    bob joined on 2013-11-17T23:00:50.606577Z

The default output format is a table of IDs with names, like this:

    $ cloudflarer zones
    1234567890abcdef1234567890abcdef website.com
    1234567890abcdef1234567890abcdff example.org
    ...

    $ cloudflarer records -z 1234567890abcdef1234567890abcdef
    2334567890abcdef1234567890abcdff A example.org 123.123.123.123
    2334567890abcdef1234567890abcdf0 AAAA example.org 2a03:1234::d0::1234:1001
    2334567892abcdef1234567892abcdf1 A sub.example.org 123.123.123.124
    ...

This output format is convenient for use in shell scripts, particularly with
awk(1). Here's how you could delete the record for sub.example.org above.

    $ ZONE=$(cloudflarer zones | awk '/example.org/{print $1}')
    $ RECORD=$(cloudflarer records -z $ZONE | awk '/sub/{print $1}')
    $ cloudflarer records delete -z $ZONE $RECORD

Besides listing zones and records in a predictible way, you can use the CLI to
create new records and modify existing ones. For example, to add a subdomain
'foo.website.com' which points to '123.123.123.125', using the example above:

    $ cloudflarer records create -z 1234567890abcdef1234567890abcdef \
        --type A --name "foo.website.com" --content "123.123.123.125"
    1827391012abcdef1234567890abcdef A foo.website.com 123.123.123.125

Modifying and deleting records is also pretty easy - for more help, see

    cloudflarer --help

once the gem is installed.

### API

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
