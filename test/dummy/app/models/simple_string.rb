class SimpleString < ActiveRecord::Base
  # attr_accessible :title, :body
  acts_with_fastaccess_on :simple_string

  def simple_string
    "this is a simple string"
  end
end
