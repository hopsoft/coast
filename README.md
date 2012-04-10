# Coast

## Providing resourceful behavior for Rails controllers

### ...if only the REST of life were this easy

Simply include the Coast module in your controller and get these actions for free.

`new` `edit` `index` `show` `create` `update` `destroy`

But wait... there's more.

* **Lightweight** - about 220 lines of code
* **Unobtrusive** - no monkey patches
* **Flexible** - support for html, xml, and json formats
* **Familiar** - Sinatra like DSL for hooking into action callbacks
* **Secure** - implicit authorization with your favorite libs... *such as CanCan*

### Works best when you stick to Rails conventions

## Quick-start for the lazy

```bash
$gem install coast
```

```ruby
# config/routes.rb
Beach::Application.routes.draw do
  resources :bums
end
```

```ruby
# app/controllers/bums_controller.rb
class BumsController < ApplicationController
  include Coast
end
```

Congratulations... you now have a RESTful API for **beach bums**.

## Callbacks

Coast uses a Sinatra like DSL to provide hooks into the action lifecycle.

The following hooks are supported for each action.

* `before` *- before any other action logic is performed... just like a Rails before_filter*
* `respond_to` *- after authorization and db work but before rendering or redirecting*
* `after` *- after all other action logic is performed... just like a Rails after_filter*

### How to use the callbacks

```ruby
# app/controllers/bums_controller.rb
class BumsController < ApplicationController
  include Coast

  before :show do
    # take control and load a 'bum' instead of letting Coast do it for us
    @resourceful_item = Bum.find(params[:id])

    # Coast will implicitly create an @bum variable that references @resourceful_item
    # cool eh?
  end

  respond_to :show do
    # take control of rendering or redirecting instead of letting Coast do it for us
    render :text => "Out surfing."
  end

  after :show do
    # do some last minute housekeeping after every thing else is done
    flash[:notice] = "Sorry... we'll be back when the surf stops crackin'"
  end

end
```

## Authorization

Coast implicitly calls an authorize method prior to executing any action logic.

You have complete control over this method. Here's an example.

```ruby
class BumsController < ApplicationController
  include Coast
  authorize_method = :authorize

  def authorize(action, data, request)
    # restrict all RESTful actions
    raise "Unauthorized"
  end

  rescue_from Exception do |ex|
    render :text => "Not Allowed", :status => 404
  end
end
```

Note the authorize method signature. The first arg is the **action** being performed. The second arg is the **record(s)** being operated on. The last arg is the **request** object.

While originally written to support CanCan, its pretty simple to take control and manage authorization yourself.

## Advanced Usage

Coast comes with few tricks up its sleeve.

You can conditionally prevent mutating behavior on the server by setting an instance variable like so.

```ruby
# app/controllers/bums_controller.rb
class BumsController < ApplicationController
  include Coast

  before :create do
    # prevent the user from actually creating a record
    @skip_db_create = true
  end

  before :update do
    # prevent the user from actually saving a record
    @skip_db_update = true
  end

  before :destroy do
    # prevent the user from actually destroying a record
    @skip_db_destroy = true
  end

end
```

Its a little arcane, but that's on purpose.

## Testing

There are some interesting additions to MiniTest::Mock since I mock some of Rails to make testing fast & fun.

Poke around the test code and let me know what you think.

How to run the tests.

```bash
$rvm 1.9.3
$gem install bundler
$bundle
$rake test
```

Ahh... passing tests.

## Contributing

I'm looking for hand-outs, so please fork and submit pull requests. Bug fixes, features, whatever...

Thanks for reading,

> Nathan

## License

### The MIT License (MIT)
Copyright (c) 2012 Nathan Hopkins

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
