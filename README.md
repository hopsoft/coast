# Coast

## Providing resourceful behavior for [Rails controllers](http://guides.rubyonrails.org/action_controller_overview.html)

![Coast GEM](http://hopsoft.github.com/coast/images/coast.png)

### ...if only the REST of life were this easy

Simply include the Coast module in your controller and get these actions for free.

`new` `edit` `index` `show` `create` `update` `destroy`

But wait... there's more.

* **Lightweight** - about 200 lines of code... *you can grok it in 5 minutes by skimming lib/coast.rb*
* **Unobtrusive** - no monkey patches
* **Flexible** - support for html, xml, and json formats
* **Familiar** - simple DSL for hooking into action callbacks
* **Secure** - implicit authorization with your favorite libs... *such as [CanCan](https://github.com/ryanb/cancan)*

### Works best when you stick to [Rails conventions](http://guides.rubyonrails.org/getting_started.html)

## Quick-start for the lazy

Assume you have a simple app structure for beach bums.

```bash
app/controllers/beach_bums_controller.rb
app/models/beach_bum.rb
```

Install the GEM.

```bash
$gem install coast
```

Tweak some files.

```ruby
# config/routes.rb
Beach::Application.routes.draw do
  resources :beach_bums
end
```

```ruby
# app/controllers/beach_bums_controller.rb
class BeachBumsController < ApplicationController
  include Coast
end
```

Congratulations... you now have a RESTful API for **beach bums**.

## Callbacks

Coast uses a [Sinatra](http://www.sinatrarb.com/) like DSL to provide hooks into the action lifecycle.

The following hooks are supported for each action.

* `before` *- before any other action logic is performed... just like a [Rails before_filter](http://guides.rubyonrails.org/action_controller_overview.html#filters)*
* `respond_to` *- after authorization and db work but before rendering or redirecting*
* `after` *- after all other action logic is performed... just like a [Rails after_filter](http://guides.rubyonrails.org/action_controller_overview.html#filters)*

### How to use the callbacks

```ruby
# app/controllers/beach_bums_controller.rb
class BeachBumsController < ApplicationController
  include Coast

  before :show do
    # take control and load a 'beach_bum' instead of letting Coast do it for us
    @resourceful_item = BeachBum.find(params[:id])

    # Coast will implicitly create an @beach_bum variable that references @resourceful_item
    # cool eh?
  end

  respond_to :show do
    # take control of rendering or redirecting instead of letting Coast do it for us
    render :text => "Out surfing."
  end

  after :show do
    # do some last minute housekeeping after every thing else is done
    Rails.logger.info "Hey brah... we just completed the show action."
  end

end
```

## Authorization

Coast implicitly calls an authorize method prior to executing any action logic.

You have complete control over this method. Here's an example.

```ruby
# app/controllers/beach_bums_controller.rb
class BeachBumsController < ApplicationController
  include Coast
  set_authorize_method :authorize

  def authorize(action, data, request)
    # restrict all RESTful actions
    raise "Unauthorized"
  end

  rescue_from Exception do |ex|
    render :text => "Not Allowed", :status => 401
  end
end
```

Note the authorize method signature. The first arg is the **action** being performed. The second arg is the **record(s)** being operated on. The last arg is the **request** object.

While originally written to support [CanCan](https://github.com/ryanb/cancan), its pretty simple to take control and manage authorization yourself.

## Advanced Usage

Coast comes with few tricks up its sleeve.

If your model and controller names deviate from Rails conventions, you can explicitly set the model like so.

```ruby
# app/controllers/beach_bums_controller.rb
class BeachBumsController < ApplicationController
  include Coast
  set_resourceful_model SurferDude
end
```

You can conditionally prevent mutating behavior on the server by setting an instance variable like so. *It's a little arcane, but that's on purpose.*

```ruby
# app/controllers/beach_bums_controller.rb
class BeachBumsController < ApplicationController
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

## Running the Tests

```bash
$ gem install coast
$ gem unpack coast
$ cd coast-[VERSION]
$ bundle
$ mt
```

Ahh... passing tests.

## Nods

[I'm tired of writing RESTful boilerplate (& scaffold is overkill), so I'm stoked natehop released the Coast gem.](https://twitter.com/tehviking/status/189739333857710080)

-- Brandon Hayes, April 10, 2012

