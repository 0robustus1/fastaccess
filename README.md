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
and stores it in a [redis][1] database.
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
