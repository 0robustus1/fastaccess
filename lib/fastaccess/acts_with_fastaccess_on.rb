module Fastaccess
  module ActsWithFastaccessOn
    extend ActiveSupport::Concern
 
    included do
    end
 
    module ClassMethods
      # registers the pertaining method as one, which return value
      # is provided through redis.
      # This is for fast access of otherwise generated content
      # with a high reading/writing ratio.
      #
      # @param [Symbol] method_name denoting the pertaining method
      #                 this method shouldn't be defined beforehand.
      # @param [Hash] options is basic options hash. 
      #               currently has no effect on execution.
      def acts_with_fastaccess_on(method_name, options = {})
        Fastaccess.register_on self, method_name, options
        # options = Fastaccess.merge_defaults(options)
        define_singleton_method :method_added do |on_method|
          if Fastaccess.registered? self, on_method
            method = on_method
            alias_name = Fastaccess.alias_for method
            if !method_defined?(alias_name)
              alias_method alias_name, method 
              define_method method do |*args|
                # fastaccess_id = Fastaccess.id_for(self)
                # redis_id = "#{method}_#{fastaccess_id}"
                redis_id = Fastaccess.redis_id_for(self, method, args)
                opts = Fastaccess.options_for(self, method)
                content_current = opts[:auto_update] ? Fastaccess.update_check(self) : true
                if Fastaccess.redis.exists(redis_id) && content_current
                  response = Fastaccess.redis.get(redis_id)
                  begin
                    return JSON.parse response
                  rescue JSON::ParserError
                    return response
                  end
                else
                  response = method(alias_name).call(*args)
                  Fastaccess.update_info self
                  Fastaccess.redis.set(redis_id, (response.is_a? String) ? response : response.to_json)
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
