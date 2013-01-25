module Fastaccess
  module Mixins
    def update_on(method, *args)
      Fastaccess.update_content(self, :on => method, :arguments => args)
    end
  end  
end
