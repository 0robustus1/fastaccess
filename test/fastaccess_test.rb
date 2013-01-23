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
end
