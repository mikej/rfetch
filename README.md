# RFetch

RFetch can be used to fetch a URL and includes methods that provide quick access to the title, description, and other meta information from the content returned.

The primary use case is automatically generating a title and preview when storing a URL within an application. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rfetch'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rfetch

## Usage

```
irb(main):012:0> result = RFetch.get("https://example.com/")
=> #<RFetch::Result url="https://example.com/" status_code=200 content_type="text/html; chars...
irb(main):013:0> page = result.to_page
=> #<RFetch::Page:0x00007fce5205ea10 @content="<!doctype html>\n<html>\n<head>\n    <title>Ex...
irb(main):014:0> page.title
=> "Example Domain"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mikej/rfetch.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
