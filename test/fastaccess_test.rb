require 'test_helper'

class FastaccessTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Fastaccess
  end

  def test_simple_redis_write_and_read
    string = SimpleString.create
    assert_equal string.simple_string, $redis.get("simple_string_#{string.class}-#{string.id}")
  end

  def test_redis_write_and_read_on_parallel_methods
    string = SimpleString.create
    assert_equal string.simple_string, $redis.get("simple_string_#{string.class}-#{string.id}")
    assert_equal string.other_string, $redis.get("other_string_#{string.class}-#{string.id}")
    assert_not_equal string.simple_string, string.other_string
  end

  def test_fastaccess_type_guessing_feature_on_array
    string = SimpleString.create
    assert_equal string.simple_array.class, Array
  end

  
  def test_fastaccess_type_guessing_feature_on_hash
    string = SimpleString.create
    assert_equal string.simple_hash.class, Hash
  end

  def test_fastaccess_type_guessing_feature_on_string
    string = SimpleString.create
    assert_equal string.simple_string.class, String
  end

  def test_autoupdate_on_fastaccess
    string = SimpleString.create
    test_string = "foobar"
    default = string.modifiable_string
    string.some_string = test_string
    string.save
    assert_not_equal default, string.modifiable_string
    assert string.modifiable_string.include?(test_string)
  end

  def test_manual_update_on_fastaccess
    string = SimpleString.create
    test_string = "foobar"
    default = string.changeable_string
    assert_equal default, string.changeable_string(test_string)
    Fastaccess::Fastaccess.update_content string, :on => :changeable_string, :arguments => [test_string]
    assert_not_equal default, string.changeable_string(test_string)
  end
end
