class SimpleString < ActiveRecord::Base
  # attr_accessible :title, :body
  acts_with_fastaccess_on :simple_string
  acts_with_fastaccess_on :other_string
  acts_with_fastaccess_on :simple_array
  acts_with_fastaccess_on :simple_hash
  acts_with_fastaccess_on :modifiable_string
  acts_with_fastaccess_on :changeable_string
  acts_with_fastaccess_on :non_autoupdateable_string, :auto_update => false
  acts_with_fastaccess_on :versioned_string, :auto_update => false, :versions => [:and, :or]
  acts_with_fastaccess_on :complex_vers_string, :auto_update => false, :versions => [[:and, 1, "foo"], [:or, 5, "bar"]]
  include Fastaccess::Mixins

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

  def non_autoupdateable_string
    return "text is something"
  end

  def versioned_string(symbol)
    case symbol
    when :and
      "simple is easy AND easy is fun"
    when :or
      "complicated isn't nice or isnt good"
    end
  end

  def complex_vers_string(*args)
    string = "if you use #{args[0]}(#{args[1]},0), you'll get: #{args[2]}"
  end

end
