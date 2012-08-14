---
layout: main
---
# Coast {#coast}

## Providing resourceful behavior for [Rails controllers](http://guides.rubyonrails.org/action_controller_overview.html) {#providing-resourceful-behavior-for-[rails-controllers](http://guides.rubyonrails.org/action_controller_overview.html)}

### ...if only the REST of life were this easy {#...if-only-the-rest-of-life-were-this-easy}

Simply include the Coast module in your controller and get these actions for free.

`new` `edit` `index` `show` `create` `update` `destroy`

But wait... there's more.

* **Lightweight** - about 200 lines of code... *you can grok it in 10 minutes by skimming lib/coast.rb*
* **Unobtrusive** - no monkey patches
* **Flexible** - support for html, xml, and json formats
* **Familiar** - [Sinatra](http://www.sinatrarb.com/) like DSL for hooking into action callbacks
* **Secure** - implicit authorization with your favorite libs... *such as [CanCan](https://github.com/ryanb/cancan)*

### Works best when you stick to [Rails conventions](http://guides.rubyonrails.org/getting_started.html) {#works-best-when-you-stick-to-[rails-conventions](http://guides.rubyonrails.org/getting_started.html)}

## Quick-start for the lazy {#quick-start-for-the-lazy}

Assume you have a simple app structure for beach bums.

{% endhighlight %}
app/controllers/beach_bums_controller.rb
app/models/beach_bum.rb
{% endhighlight %}

Install the GEM.

{% endhighlight %}
$gem install coast
{% endhighlight %}

Tweak some files.

{% highlight ruby %}
# config/routes.rb {#config/routes.rb}
Beach::Application.routes.draw do
  resources :beach_bums
end
{% endhighlight %}

{% highlight ruby %}
# app/controllers/beach_bums_controller.rb {#app/controllers/beach_bums_controller.rb}
class BeachBumsController < ApplicationController
  include Coast
end
{% endhighlight %}

Congratulations... you now have a RESTful API for **beach bums**.

## Callbacks {#callbacks}

Coast uses a [Sinatra](http://www.sinatrarb.com/) like DSL to provide hooks into the action lifecycle.

The following hooks are supported for each action.

* `before` *- before any other action logic is performed... just like a [Rails before_filter](http://guides.rubyonrails.org/action_controller_overview.html#filters)*
* `respond_to` *- after authorization and db work but before rendering or redirecting*
* `after` *- after all other action logic is performed... just like a [Rails after_filter](http://guides.rubyonrails.org/action_controller_overview.html#filters)*

### How to use the callbacks {#how-to-use-the-callbacks}

{% highlight ruby %}
# app/controllers/beach_bums_controller.rb {#app/controllers/beach_bums_controller.rb}
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
    flash[:notice] = "Sorry brah... we'll be back when the surf stops crackin'"
  end

end
{% endhighlight %}

## Authorization {#authorization}

Coast implicitly calls an authorize method prior to executing any action logic.

You have complete control over this method. Here's an example.

{% highlight ruby %}
# app/controllers/beach_bums_controller.rb {#app/controllers/beach_bums_controller.rb}
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
{% endhighlight %}

Note the authorize method signature. The first arg is the **action** being performed. The second arg is the **record(s)** being operated on. The last arg is the **request** object.

While originally written to support [CanCan](https://github.com/ryanb/cancan), its pretty simple to take control and manage authorization yourself.

## Advanced Usage {#advanced-usage}

Coast comes with few tricks up its sleeve.

If your model and controller names deviate from Rails conventions, you can explicitly set the model like so.

{% highlight ruby %}
# app/controllers/beach_bums_controller.rb {#app/controllers/beach_bums_controller.rb}
class BeachBumsController < ApplicationController
  include Coast
  set_resourceful_model SurferDude
end
{% endhighlight %}

You can conditionally prevent mutating behavior on the server by setting an instance variable like so. *It's a little arcane, but that's on purpose.*

{% highlight ruby %}
# app/controllers/beach_bums_controller.rb {#app/controllers/beach_bums_controller.rb}
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
{% endhighlight %}

## Testing {#testing}

There are some interesting additions to MiniTest::Mock since I mock some of Rails to make testing fast & fun.

Poke around the test code and let me know what you think.

How to run the tests.

{% endhighlight %}
$rvm 1.9.3
$gem install bundler
$bundle
$rake test
{% endhighlight %}

Ahh... passing tests.

## Contributing {#contributing}

I'm looking for hand-outs, so please fork and submit pull requests. Bug fixes, features, whatever...

## Nods {#nods}

<blockquote class="twitter-tweet"><p>I'm tired of writing RESTful boilerplate (& scaffold is overkill), so I'm stoked @<a href="https://twitter.com/natehop">natehop</a> released the Coast gem: <a href="https://t.co/gjCukFoW" title="https://github.com/hopsoft/coast">github.com/hopsoft/coast</a></p>&mdash; Brandon Hays (@tehviking) <a href="https://twitter.com/tehviking/status/189739333857710080" data-datetime="2012-04-10T15:39:17+00:00">April 10, 2012</a></blockquote>
<script src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

## License {#license}

### The MIT License (MIT) {#the-mit-license-(mit)}
Copyright (c) 2012 Nathan Hopkins

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
