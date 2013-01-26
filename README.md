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
