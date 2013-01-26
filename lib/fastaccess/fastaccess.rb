require 'set'

module Fastaccess
  # This class contains the most
  # relevant helpers methods, which
  # doesn't need to be located elsewhere.
  # (e.g. like mixins)
  class Fastaccess
    @@fastaccess_on = Hash.new Set.new
    @@last_updated  = Hash.new

    # accessor for the actual registration hash.
    cattr_accessor :fastaccess_on

    # hash for monitoring updates on registered objects.
    cattr_accessor :last_updated
    
    # registers a method, defined on a certain class,
    # as being handled by fastaccess.
    # @param [Class] class_name is the actual Class.
    # @param [Symbol] method_name is the symbol
    #                 denoting the actual method
    def self.register_on(class_name, method_name)
      self.fastaccess_on[class_name] << method_name
    end

    # inquires if a certain method, which is
    # defined on a given class, is registered
    # with fastaccess.
    # @param [Class] class_name is the actual Class.
    # @param [Symbol] method_name is the symbol
    #                 denoting the actual method
    def self.registered?(class_name, method_name)
      self.fastaccess_on[class_name].include? method_name
    end

    # checks if a class_instance seems to be
    # up to date according to updated_at timestamp.
    # This only works if the registered method 
    # is actually dependent (and only dependent)
    # on model attributes.
    # @param [Object] class_instance any Object,
    #                 preferably a decendent of
    #                 an actual Rails Model.
    # @return [Boolean] is true if everything is up to date.
    def self.update_check(class_instance)
      id = self.id_for(class_instance)
      class_instance.updated_at == self.last_updated[id]
    end
    
    # updates the timestamp in the redis
    # database with the one from class_instance.
    # usually called after there was new content
    # pushed into redis (or content was updated)
    # @param [Object] class_instance any Object,
    #                 preferably a decendent of
    #                 an actual Rails Model.
    def self.update_info(class_instance)
      id = self.id_for(class_instance)
      self.last_updated[id] = class_instance.updated_at
    end

    # creates a fastaccess id for a class_instance
    # @param [Object] class_instance any Object,
    #                 preferably a decendent of
    #                 an actual Rails Model.
    def self.id_for(class_instance)
      "#{class_instance.class}-#{class_instance.id}"
    end

    # returns the aliased name for
    # any given method. 
    # @param [Symbol] method a symbol denoting the method.
    # @return [Symbol] aliased method symbol.
    def self.alias_for(method)
      :"aliased_#{method}"
    end

    # setting content in redis
    # @param [String] redis_id the id
    # @param [Object] content should be basic content
    #                 e.g. String, Hash, Array or Numbers.
    def self.set(redis_id, content)
      $redis.set(redis_id, (content.is_a? String) ? content : content.to_json)
    end

    # getting redis content
    # @param [String] redis_id the id
    # @return [Object] stored content
    def self.get(redis_id)
      response = $redis.get(redis_id)
      begin
        return JSON.parse response
      rescue JSON::ParserError
        return response
      end
    end

    # manually update content in redis
    # for a given object.
    # @param [Object] obj any Object,
    #                 preferably a decendent of
    #                 an actual Rails Model.
    # @param [Hash] options a simple hash
    # @option options [Symbol] :on a certain registered
    #                          method.
    # @option options [Array] :arguments an array of
    #                         arguments passed to
    #                         the :on method or, if
    #                         :on is not present, every
    #                         method registered with fastaccess
    #                         on the pertaining class.
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
