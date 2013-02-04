# fastaccess - redisfast access on generated content

Many web applications which provide textual content to the user
have much more reads than writes. This can mean, that on
every 10k reads there is one write (see some popular
blogs or newspages). 

Often this content is generated, because the input source
is some markup format, like markdown. This means, that
there is always the need to generate this content into
html. 

And this is why fastaccess exists. 
It modifies any given method, which generates content,
and stores it in a [redis][redis] database.
If this content solely depends on a model attribute,
for example like the *body* in a blog post, it will
be auto updated, if the underlying model attribute
changes. Otherwise you can trigger the update manually.

Now lets see how this works:

## Using fastaccess

First, of course, you'll need to include this gem in your
projects *Gemfile*.

Since this gem utilizes redis, make sure that this is installed
and generate the default initializer with

    rails generate fastaccess:initialize

This will create a file in *config/initializers/fastaccess.rb* which
will create an instance of a redis database-connection. If you already
have one of those, feel free to replace the new instance with your version.

Now, in your project you will have to use the gem-provided
`acts_with_fastaccess_on` method to mark certain methods
as registered with fastaccess for caching.

```ruby
class Post < ActiveRecord::Base
  attr_accessible :title, :body
  acts_with_fastaccess_on :markdown_body

  def markdown_body
    markdown(self.body)
  end
end
```

In this example a Model named *Post* is defined which has title and
body attributes. The `markdown_body` method converts the markdown-body to
html. Since this is needed often, it cached via redis.

The previous example utilizes a method, which operates on one of the models
attributes. So the redis-content will be updated if the pertaining Model
instance is updated. But what if you have a method which uses more input
than just specific attributes, which will update the models timestamp?

For this case there is an explicit update method, which allows you
to trigger an update.

```ruby
# app/models/post.rb
class Post < ActiveRecord::Base
  attr_accessible :title, :body, :tags
  has_many :tags
  acts_with_fastaccess_on :tag_list
  include Fastaccess::Mixins
  
  def tag_list
    self.tags.map(&name)
  end
end

# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  def update
    @post = Post.find_by_id(params[:id])
    @post.update_on :tag_list
    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end 
  end
end
```

If you don't want to *pollute* your model with these mixin-methods you
can also call 

```ruby
Fastaccess::Fastaccess.update_content @post, :on => :tag_list, :arguments => []
```

## Features

### planned features

- ~~disable auto-update via option setting (planned for *0.0.2*)~~ *implemented*
- more update flexibility
  - e.g. custom update-constraints instead of calling `update_content` manually
- **version**  
  sometimes parameters passed to the watched method aren't arbitrary,
  but contain some sort of state. So some output-*versions* of the
  generated content are used, with evenly distributed odds.
  Fastaccess should allow for these versions to exist in memory.
  This means, that certain *sets of arguments* are bundling
  a so called version, which should be accessible via redis for
  more flexibility.

## License

([The MIT License][mit])

Copyright © 2013:

- [Tim Reddehase][1]

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[mit]: http://opensource.org/licenses/MIT
[redis]: http://redis.io/
[1]: http://rightsrestricted.com
