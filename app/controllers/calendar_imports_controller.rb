class CalendarImportsController < ApplicationController
  layout 'base'

  def index
    @user = User.current
  end
end
