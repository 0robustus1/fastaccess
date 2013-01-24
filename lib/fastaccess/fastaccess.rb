require 'set'

module Fastaccess
  class Fastaccess
    @@fastaccess_on = Hash.new Set.new
    cattr_accessor :fastaccess_on
    
    def self.register_on(class_name, method_name)
      self.fastaccess_on[class_name] << method_name
    end

    def self.registered?(class_name, method_name)
      self.fastaccess_on[class_name].include? method_name
    end
  end
end
