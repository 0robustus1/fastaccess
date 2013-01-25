module Fastaccess
  module ActsWithFastaccessOn
    extend ActiveSupport::Concern
 
    included do
    end
 
    module ClassMethods
      def acts_with_fastaccess_on(method_name, options = {})
        Fastaccess.register_on self, method_name
        define_singleton_method :method_added do |on_method|
          if Fastaccess.registered? self, on_method
            method = on_method
            alias_name = Fastaccess.alias_for method
            if !method_defined?(alias_name)
              alias_method alias_name, method 
              define_method method do |*args|
                fastaccess_id = Fastaccess.id_for(self)
                redis_id = "#{method}_#{fastaccess_id}"
                if $redis.exists(redis_id) && Fastaccess.update_check(self)
                  response = $redis.get(redis_id)
                  begin
                    return JSON.parse response
                  rescue JSON::ParserError
                    return response
                  end
                else
                  response = method(alias_name).call(*args)
                  Fastaccess.update_info self
                  $redis.set(redis_id, (response.is_a? String) ? response : response.to_json)
                  return response
                end
              end
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Fastaccess::ActsWithFastaccessOn
