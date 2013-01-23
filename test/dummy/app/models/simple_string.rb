class SimpleString < ActiveRecord::Base
  # attr_accessible :title, :body
  acts_with_fastaccess_on :simple_string
  acts_with_fastaccess_on :other_string
  acts_with_fastaccess_on :simple_array
  acts_with_fastaccess_on :simple_hash

  def simple_string
    "this is a simple string"
  end

  def other_string
    "this is another string"
  end

  def simple_array
    ["first_element", "second_element"]
  end

  def simple_hash
    {:firstly => "we'll do this", :secondly => "we'll try this"}
  end

end
