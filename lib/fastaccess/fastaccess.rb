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
  end
end
