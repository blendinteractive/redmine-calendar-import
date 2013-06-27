require File.expand_path(File.dirname(__FILE__) + '../../test_helper.rb')

class UserCalendarTest < ActiveSupport::TestCase
  test "User Calendars require a user" do
    calendar = UserCalendar.new
    assert_equal false, calendar.save
  end
end