module Fastaccess
  # optional Mixins which make
  # working with fastaccess easier, but can
  # be seen as pollution of the models, so
  # their use is optional. 
  # (needs include Fastaccess::Mixins)
  module Mixins
    # convenience method for {Fastaccess::Fastaccess.update_content}
    def update_on(method, *args)
      Fastaccess.update_content(self, :on => method, :arguments => args)
    end
  end  
end
