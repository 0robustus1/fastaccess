require 'set'
require 'digest/sha2'

module Fastaccess
  # This class contains the most
  # relevant helpers methods, which
  # doesn't need to be located elsewhere.
  # (e.g. like mixins)
  class Fastaccess

    # the default options for the
    # acts_with_fastaccess_on method.
    ACTS_OPTIONS_DEFAULTS = {
      :auto_update => true,
      :versions    => [],
    }

    @@fastaccess_on = Hash.new Set.new
    @@last_updated  = Hash.new
    @@registered_options = Hash.new ACTS_OPTIONS_DEFAULTS

    # accessor for the actual registration hash.
    cattr_accessor :fastaccess_on

    # hash for monitoring updates on registered objects.
    cattr_accessor :last_updated

    # hash for options of registered methods
    cattr_accessor :registered_options

    # registers a method, defined on a certain class,
    # as being handled by fastaccess.
    # @param [Class] class_name is the actual Class.
    # @param [Symbol] method_name is the symbol
    #                 denoting the actual method
    def self.register_on(class_name, method_name, options={})
      self.fastaccess_on[class_name] << method_name
      id = options_id_for(class_name, method_name)
      self.registered_options[id] = self.registered_options[id].merge(options)
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

    # gets the options for a class_name, method_name
    # pair
    # @param [Class] class_name is the actual Class.
    # @param [Symbol] method_name is the symbol
    #                 denoting the actual method
    # @return [Hash] the options for the pair
    def self.options_for(class_name, method_name)
      id = options_id_for(class_name, method_name)
      self.registered_options[id]
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
      return true if self.last_updated[id] == false
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
      unless self.last_updated[id] == false
        self.last_updated[id] = class_instance.updated_at
      end
    end

    # creates a fastaccess id for a class_instance
    # @param [Object] class_instance any Object,
    #                 preferably a decendent of
    #                 an actual Rails Model.
    # @return [String] the identifier
    def self.id_for(class_instance)
      "#{class_instance.class}-#{class_instance.id}"
    end

    # creates the id for the registered_options hash
    # @param [Class] class_name a class singleton object
    # @param [Symbol] method_name is the identifying symbol of a method
    # @return [String] the identifier
    def self.options_id_for(class_name, method_name)
      "#{class_name}-#{method_name}"
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
      redis.set(redis_id, (content.is_a? String) ? content : content.to_json)
    end

    # getting redis content
    # @param [String] redis_id the id
    # @return [Object] stored content
    def self.get(redis_id)
      response = redis.get(redis_id)
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

    # setting up the environment for fastaccess 
    def self.setup(&block)
      instance_eval &block if block_given?
    end

    # setting the global redis instance for fastaccess.
    # @param [Redis] redis_instance The Connection to a redis server
    def self.set_redis(redis_instance)
      if redis_instance
        @@redis = redis_instance 
      else
        @@redis = $redis if $redis
      end
    end

    # getting the redis instance 
    # @return [Redis] the instance
    def self.redis
      @@redis
    end

    # merges the, hopefully, reasonable
    # defaults with the supplied options
    # hash
    # @param [Hash] options the pertaining options
    #               supplied by the user
    # @return [Hash] the merged options hash
    def self.merge_defaults(options)
      ACTS_OPTIONS_DEFAULTS.merge(options)
    end

    # returns the id used by fastaccess for
    # the storage of content in the redis database
    # @param [Object] class_instance instance of a registered class
    # @param [Symbol] method is a symbol denoting the called method
    # @param [Array] args arguments supplied to the method on the call
    def self.redis_id_for(class_instance, method, args=[])
      opts = self.options_for(class_instance.class, method)
      fastaccess_id = self.id_for(class_instance) 
      base_id = "#{method}_#{fastaccess_id}"
      return base_id if opts[:versions].empty?
      opts[:versions].each do |version|
        if self.match_version(version, args)
          sha = Digest::SHA2.new << version.inspect         
          return "#{base_id}:#{sha}"
        end
      end
      base_id
    end

    private
    # tries to match a version
    # against given arguments
    def self.match_version(version, args)
      arr_version = version.is_a?(Array) ? version : [version]
      arr_version == args
    end

  end

end
