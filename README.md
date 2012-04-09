# Coast

### ...if only the REST of life were this easy

Coast provides resourceful behavior for Rails controllers.

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
* Sinatra like **DSL** for hooking into those callbacks
* **Implicit security** via authorization with your favorite libs *...such as CanCan*

## TL;DR

**Quick-start for the lazy**

```bash
$gem install coast
```

```ruby
# config/routes.rb
Lazy::Application.routes.draw do
  resources :bums
end
```

```# app/controllers/bums_controller.rb
class BumsController < ApplicationController
  include Coast
end
```

Congratulations... you now have a RESTful API for **lazy bums**.

## Callbacks

Coast uses a Sinatra like DSL to provide you with access points into the action lifecycle.
The following hooks are supported for each action.

* before *- before any other action logic is performed*
* respond_to *- after authorization and db work but before rendering*
* after *- after all other logic*

Here are some examples of how to use this stuff.

```ruby
# soon...
```

## Authorization





# The MIT License (MIT)
Copyright (c) 2012 Nathan Hopkins

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
