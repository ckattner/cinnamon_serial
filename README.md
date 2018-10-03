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

### Getting Started

Consider the following class:

```
class Employee
  attr_accessor :id, :first_name, :last_name, :active, :account, :progress, :start_date
end
```

We could create a simple 1:1 serializer like so:

```
class EmployeeSerializer < CinnamonSerial::Base
  serialize :id, :first_name, :last_name, :active, :account, :progress, :start_date
end
```

To use this serializer:

```
employee = Employee.new
# populate employee data...
serializer = EmployeeSerializer.new(employee)
data = serializer.as_json
```

The 'data' variable above is now a hash with only data as specified by the serializer.

### Dynamic Attributes

Serialized keys do not have to match the composed object.  Using our examples above we could
create another serializer:

```
class EmployeeListSerializer < CinnamonSerial::Base
  serialize :id
  serialize :proper_name, to: :last_name
end
```

In this case the serialized data will contain a key 'proper_name' instead of 'last_name'.

### Calling Methods

serialized keys are not limited to just attributes, in fact, it will just test the model to see if the
composed object responds to the key and if it does it will send to the object.  For example:

```
class FormalEmployee < Employee
  def proper_name
  "#{last_name}, #{first_name}"
  end
end
```

```
class EmployeeListSerializer < CinnamonSerial::Base
  serialize :id, :proper_name
end
```

### Value Aliasing

Note: Internationalization is an incredibly complex problem that this library will not try to solve but it does provide the ability to override resolved values.  In the future the aliasing and formatting abilities should be extracted and plugged-in as to provide internationalization support.

You are allowed to override the value if a value has been resolved to one of the following:

1. true
2. false
3. nil
4. 'present'
5. 'blank'

Say you want to show Yes/No/Unknown for a boolean value.  Building on our previous Employee examples we could modify our EmployeeSerializer:

```
class EmployeeSerializer < CinnamonSerial::Base
  serialize :id, :first_name, :last_name
  serialize :active, true_alias: 'Yes', false_alias: 'No', null: 'Unknown'
end
```

Now the value of active will be 'Yes', 'No', or 'Unknown' instead of true, false, or null.

### Value Formatting

Two basic formatters that come included with this library are:

1. Masking (defaults to masking all but last 4 characters with character X)
2. Percent Formatting (two decimal places)

An example of custom formatters would be:

```
class EmployeeSerializer < CinnamonSerial::Base
  serialize :id, :first_name, :last_name
  serialize :account, mask: true
  serialize :progress, percent: true
end
```

Account will be formatted as a masked string and progress will be converted to a percent formatted string.

### Custom Methods

There are two ways to specify to execute a method on the serializer:

1. Method - call an instance method with no arguments.
2. Transform - Resolve the value first then pass it into an instance method.

For example:

```
class EmployeeSerializer < CinnamonSerial::Base
  serialize :id, :first_name, :last_name, :start_date
  serialize :renewal_date,  for: :start_date, transform: true
  serialize :user_id, method: true

  private

  def renewal_date(date)
    # Two years out
    date + (60 * 60 * 24 * 24)
  end

  def user_id
    dig_opt(:user, :id)
  end
end
```

Some notes about the above example:

* You can either pass in true (it will call the method named as the key) or the explicit name of the method.
* dig_opt is a convenience method that will call dig on the serializer options (second argument in serializer constructor.)

### Custom Code

In you need full control over serialization you can create hydrate blocks of code that will execute (in order of declaration.)  For example:

```
class EmployeeSerializer < CinnamonSerial::Base
  serialize :id, :first_name, :last_name, :start_date
  serialize :active, manual: true

  hydrate do
    set_active(obj.start_date >= Date.today)
  end
end
```

some notes about the above example:

* setting manual to true declares that no mapping should be automatically performed.  Instead, you must set it within the hydrate block.
* set_* are magic methods that will set the value to the value passed in.  In this context we will set the 'active' value to true if the start_date is either today or earlier than today.
* obj is the composed object (in this context it would be the Employee instance.)  You are allowed to access it using the obj getter.  In the same vain, you are also allowed to access the serializer options using 'opts' getter.

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
