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

end
