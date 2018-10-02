# Cinnamon Serial

[![Build Status](https://travis-ci.org/bluemarblepayroll/cinnamon_serial.svg?branch=master)](https://travis-ci.org/bluemarblepayroll/cinnamon_serial)

A common issue is that we typically want different data going
outbound than what we have available server-side.  Some example motivations could be:

* I have too much data, I want to slim down the outbound request.
* I do not have enough data, I need to get more and send that as well.
* I do not want to expose some data due to security/authorization concerns.

Having a separate layer that specializes in this type of materialization is important no matter 
what the reasons are.  This library provides a simple domain-specific language that makes creating
serializers or serialization layers declarative and easy.

## Installation

To install through Rubygems:

````
gem install install cinnamon_serial
````

You can also add this to your Gemfile:

````
bundle add cinnamon_serial
````

## Examples

todo.

## Contributing

### Development Environment Configuration

Basic steps to take to get this repository compiling:

1. Install [Ruby](https://www.ruby-lang.org/en/documentation/installation/) (check cinnamon_serial.gemspec for versions supported)
2. Install bundler (gem install bundler)
3. Clone the repository (git clone git@github.com:bluemarblepayroll/cinnamon_serial.git)
4. Navigate to the root folder (cd cinnamon_serial)
5. Install dependencies (bundle)

### Running Tests

To execute the test suite run:

````
rspec
````

## License

This project is MIT Licensed.
