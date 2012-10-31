# Labs::Deployer

Thor task to help w/ deployment of cookbooks to S3 for use by Chef-Solo

## Installation

Add this line to your application's Gemfile:

    gem 'labs-deployer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install labs-deployer

## Usage

Thos task that helps bundle and deploy cookbooks to S3.  Expects the following in your knife.rb

```ruby

knife[:aws_access_key_id]      = "abc123"
knife[:aws_secret_access_key]  = "abc123"
knife[:bucket]  = 'cookbooks.myserver.com'
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
