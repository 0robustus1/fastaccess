class SimpleString < ActiveRecord::Base
  # attr_accessible :title, :body
  acts_with_fastaccess_on :simple_string
  acts_with_fastaccess_on :other_string
  acts_with_fastaccess_on :simple_array
  acts_with_fastaccess_on :simple_hash
  acts_with_fastaccess_on :modifiable_string
  acts_with_fastaccess_on :changeable_string
  include Fastaccess::Mixins

  attr_accessible :some_string

  def simple_string
    "this is a simple string"
  end

  def other_string
    "this is another string"
  end

  def modifiable_string
    "text is #{self.some_string}"
  end

  def simple_array
    ["first_element", "second_element"]
  end

  def simple_hash
    {:firstly => "we'll do this", :secondly => "we'll try this"}
  end

  def changeable_string(string="this is default")
    return string
  end

end
