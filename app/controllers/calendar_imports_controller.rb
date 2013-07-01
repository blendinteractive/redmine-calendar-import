# Calendar Importer - plugin for redmine project management software
# Copyright (C) 2007-2012  Blend Interactive
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class CalendarImportsController < ApplicationController
  unloadable
  layout 'base'

  def index
    @user = User.current
    @user_calendar = UserCalendar.new
    @errors = Error.find(:all)
    #UserToProjectMapping.find(@user.id)
  end

  def user_index
  	#TODO restrict this to admins
  	split = params[:name].split(',')
  	firstname = split[0]
  	lastname = split[1]
  	@user = User.find_by_firstname_and_lastname(firstname,lastname)
  	@user_calendar = UserCalendar.new
  	
  	render "index"
  end

  def user_pull
    split = params[:name].split(',')
    firstname = split[0]
    lastname = split[1]
    @user = User.find_by_firstname_and_lastname(firstname,lastname)
    ImportProcessor::process_user(@user)
    @user_calendar = UserCalendar.new

    render 'index'
  end
end
