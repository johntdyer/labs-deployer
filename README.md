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

Thos task that helps bundle and deploy cookbooks to S3.  Ascends path looking for .deployer file.  A local .deployer files attributes will take precedence over one in a higher scope.  The contents of this file should contain one or more of the following:

```ruby
bucket_name: cookbooks.something.com
aws_key: abc
aws_secret: 123
project_name: tropo/12.0/cookbooks/functional_deployment
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
