require 'set'

module Fastaccess
  class Fastaccess
    @@fastaccess_on = Hash.new Set.new
    @@last_updated  = Hash.new
    cattr_accessor :fastaccess_on
    cattr_accessor :last_updated
    
    def self.register_on(class_name, method_name)
      self.fastaccess_on[class_name] << method_name
    end

    def self.registered?(class_name, method_name)
      self.fastaccess_on[class_name].include? method_name
    end

    def self.update_check(class_instance)
      id = self.id_for(class_instance)
      class_instance.updated_at == self.last_updated[id]
    end
    
    def self.update_info(class_instance)
      id = self.id_for(class_instance)
      self.last_updated[id] = class_instance.updated_at
    end

    def self.id_for(class_instance)
      "#{class_instance.class}-#{class_instance.id}"
    end

    def self.alias_for(method)
      :"aliased_#{method}"
    end

    def self.set(redis_id, content)
      $redis.set(redis_id, (content.is_a? String) ? content : content.to_json)
    end

    def self.get(redis_id)
      response = $redis.get(redis_id)
      begin
        return JSON.parse response
      rescue JSON::ParserError
        return response
      end
    end

    def self.update_content(obj, options={})
      class_name = obj.is_a?(Class) ? obj : obj.class
      methods = if method = options[:on]
        if registered? class_name, method
          [method]
        else
          []
        end
      else
        fastaccess_on[class_name]
      end
      methods.each do |method|
        callable = obj.method( alias_for(method) )
        content = if options[:arguments]
                    callable.call(*options[:arguments])
                  else
                    callable.call
                  end
        self.set("#{method}_#{id_for(obj)}", content)
      end
    end
  end
end
