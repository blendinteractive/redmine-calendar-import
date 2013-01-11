require File.expand_path(File.dirname(__FILE__) + '../../test_helper.rb')
require File.expand_path(File.dirname(__FILE__) + '../../../script/utilities.rb')

class UtilitiesTest < ActiveSupport::TestCase
  test "0 Minutes Rounds to 0" do
    assert_equal 0, round_to_15_minutes(0)
  end

  test "120 Minutes Rounds to 120" do
    assert_equal 120, round_to_15_minutes(120)
  end

  test "1 Minute Rounds to 15" do
    assert_equal 15, round_to_15_minutes(1)
  end

  test "217 Minutes Rounds to 225" do
    assert_equal 225, round_to_15_minutes(217)
  end
end