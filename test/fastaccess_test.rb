require 'test_helper'

class FastaccessTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Fastaccess
  end

  def test_hickwalls_squawk_should_populate_last_squawk
    string = SimpleString.create
    assert_equal string.simple_string, $redis.get("simple_string_#{string.class}-#{string.id}")
  end
end
