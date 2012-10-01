class CalendarImportsController < ApplicationController
  unloadable
  layout 'base'

  def index
    @user = User.current
    @user_calendar = UserCalendar.new
    #UserToProjectMapping.find(@user.id)
  end
end
