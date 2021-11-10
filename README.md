# yep

A simple, thread-safe dependency injection framework written in ruby.

## Install

From the command line
```
gem install yep
```

From a Gemfile
```
source 'http://rubygems.org'

gem 'yep'
```

## Usage

In the following example we will use a simple convoluted application that
queries an external API for user data.

```ruby
require 'net/http'
require 'json'

class RandomUserRepository
  class << self
    def random
      response = Net::HTTP.get(URI('https://randomuser.me/api'))    
      JSON.parse(response)
    end
  end
end
```

```ruby
class User
  attr_accessor :name

  def random
    users = RandomUserRepository.random
    self.name = users['results'][0]['name']['first']
    self
  end 
end
```

The problem with the code above is that the `User` class has a hard dependency
on the `RandomUserRepository`. This has two negative side effects. 

It would not be simple in a larger application to swap out the
`RandomUserRepository` and all the places it ends up being littered throughout
the application for another implementation of the repository such as
`SqlUserRepository`. 

It would not be simple and concise to swap out the `RandomUserRepository` for
testing purposes, maybe for something like a `TestUserRepository`.

So lets have a look at dependency injection with `yep` to see how this can be
solved.

### Container

The container will store dependencies registered under keys which can then later
be resolved. Registration of dependencies should happen once for an application.

```ruby
require 'yep'

class App

  def self.boot
    Yep::Container.add(:repository, RandomUserRepository,
        Yep::Container::SINGLETON)
    Yep::Container.add(:user, User, Yep::Container::INSTANCE)
  end
end

App.boot
```

During boot we register classes under a keys then assign a lifetime to the
registered classes. 

If `Yep::Container::SINGLETON` is used as a lifetime, every time the dependency
is resolved the container will return the same instance of a class.

If `Yep::Container::INSTANCE` is used as a lifetime, every time the dependency
is resolve the container will return a new instance of a class.

### Injector

Now the dependencies are registered to the container lets change the `User`
class have the repository injected into the user class.

```ruby
class User
  extend Yep::Inject

  attr_accessor :name

  inject(:repository)

  def random
    users = repository.random
    self.name = users['results'][0]['name']['first']
    self
  end
end
```

By extending `Yep::Inject` you then have access to call the `inject` method.
By calling this method it will set an instance variable with the same key as the
registered dependency, in this case `repository`. Now by calling
`User.new.repository` the `RandomUserRepository` will be returned from the 
container.

If at anytime you wanted to swap out and use a different repository, as long
as it has the same method signatures and returns the same data structures, you
can just change the dependency on the container.

Example:

A new repository that reads from a SQL database.

```ruby
class SqlUserRepository
  include Sql

  class << self
    def random
      response = db.read('SELECT * FROM users LIMIT 1 ORDER BY RAND()')
      JSON.parse(response)
    end
  end
end
```

Change the dependency of repository during boot.

```ruby
require 'yep'

class App

  def self.boot
    Yep::Container.add(:repository, SqlUserRepository,
        Yep::Container::SINGLETON)
    Yep::Container.add(:user, User, Yep::Container::INSTANCE)
  end
end

App.boot
```

Now by calling `User.new.repository` the `SqlUerRepository` will be returned 
from the container.

*Note:* By calling `Yep::Container.resolve(:repository)` you can
programmatically resolve a dependency from the container.

### Testing

When testing you may want to mock how the dependences are resolved.

In this example we mock the Users repository call to return a reliable set of
data for testing.

```ruby
class FakeUserRepository
  class << self
    def random
      JSON.parse('{ "results": [ { "name": { "first": "FakeName" }}] }')
    end
  end
end
```

```ruby
require 'minitest/autorun'

require 'yep'

class TestUser < Minitest::Test
  User.enable_dependency_mocks!

  def test_name_is_set_after_random_is_called
    user = User.new
    user.mock(:repository, FakeUserRepository)
    user.random

    assert user.name == 'FakeName'
    
    user.unmock(:repository)
  end
```

In this example the underlying repository is swapped out to make sure the call
to `random` will return reliable data. After the test finished the repository
is then unmocked (returned back to it's original state)

## Licence

See `LICENCE` file.

## Development

### Prerequisites

* Docker Community Edition - https://www.docker.com/community-edition
* Docker Compose - https://docs.docker.com/compose/
* Make - https://www.gnu.org/software/make/

### Setup

* `make` will build the application ready for use.

### Lint

* `make lint` will run linting

### Tests

* `make spec` will run tests

