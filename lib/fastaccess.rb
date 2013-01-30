require 'redis'
require 'fastaccess/fastaccess.rb'
require 'fastaccess/mixins.rb'
require 'fastaccess/acts_with_fastaccess_on'

module Fastaccess

  # convenience method to setup fastaccess
  def self.setup(&block)
    Fastaccess.setup &block
  end

end
