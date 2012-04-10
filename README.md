# Coast

## ...if only the REST of life were this easy.

### Coast provides resourceful behavior for Rails controllers.

Simply include a single module in your controller and get these actions for free.

* new
* edit
* index
* show
* create
* update
* destroy

But wait... there's more.

* Support for **html, xml, and json** formats
* Sinatra like **DSL** for hooking into action callbacks
* **Implicit security** via authorization with your favorite libs *...such as CanCan*

&nbsp;
### Works best when you stick to Rails conventions.

*Actually... bad things happen if you stray from the straight & narrow.*

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

Coast uses a Sinatra like DSL to provide you with hooks into the action lifecycle.
The following hooks are supported for each action.

* before *- before any other action logic is performed*
* respond_to *- after authorization and db work but before rendering or redirecting*
* after *- after all other action logic is performed*

### How to use the callbacks.

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
    render :text => "Out Fishing."
  end

  after :show do
    # do some last minute housekeeping after every thing else is done
    flash[:notice] = "Sorry... we'll be back soon."
  end

end
```

## Authorization





# The MIT License (MIT)
Copyright (c) 2012 Nathan Hopkins

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
