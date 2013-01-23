module Fastaccess
  module ActsWithFastaccessOn
    extend ActiveSupport::Concern
 
    included do
    end
 
    module ClassMethods
      def acts_with_fastaccess_on(method, options = {})
        self.define_singleton_method :method_added do |on_method|
          if on_method == method
            alias_name = :"aliased_#{method}"
            self.alias_method alias_name, method 
            self.define_method method do |*args|
              redis_id = "#{method}_#{self.class}-#{self.id}"
              if $redis.exists redis_id
                return $redis.get redis_id
              else
                response = self.class.call(alias_name, *args)
                $redis.set redis_id, response
                return response
              end
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Fastaccess::ActsWithFastaccessOn
