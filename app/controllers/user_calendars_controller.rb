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

class UserCalendarsController < ApplicationController
  unloadable
  layout 'base'

  def just_user_calendars
    @user = User.find(params[:user_id])
    render :partial=>"calendar_imports/user_calendar_list", :locals=>{:user_calendars=>@user.user_calendars}
  end

  # GET /user_calendars
  # GET /user_calendars.xml
  def index
    @user_calendars = UserCalendar.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_calendars }
    end
  end

  # GET /user_calendars/1
  # GET /user_calendars/1.xml
  def show
    @user_calendar = UserCalendar.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_calendar }
    end
  end

  # GET /user_calendars/new
  # GET /user_calendars/new.xml
  def new
    @user_calendar = UserCalendar.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_calendar }
    end
  end

  # GET /user_calendars/1/edit
  def edit
    @user_calendar = UserCalendar.find(params[:id])
  end

  # POST /user_calendars
  # POST /user_calendars.xml
  def create
    @user_calendar = UserCalendar.new(params[:user_calendar])

    @user_calendar.save
    flash[:notice] = "The calendar #{@user_calendar.name} was successfully created."
    redirect_to(url_for :controller => "calendar_imports", :action => "index")


  end

  # PUT /user_calendars/1
  # PUT /user_calendars/1.xml
  def update
    @user_calendar = UserCalendar.find(params[:id])

    respond_to do |format|
      if @user_calendar.update_attributes(params[:user_calendar])
        flash[:notice] = 'UserCalendar was successfully updated.'
        format.html { redirect_to(@user_calendar) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_calendar.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_calendars/1
  # DELETE /user_calendars/1.xml
  def destroy
    unless params[:id]
      raise "No ID passed"
    end
    puts params[:id]

    @user_calendar = UserCalendar.find(params[:id])
    @name = @user_calendar.name
    @user_calendar.destroy
    respond_to do |format|
      flash[:notice] = "The calendar '#{@name}' was successfully removed."
      format.html { redirect_to(url_for :controller => "calendar_imports", :action => "index") }
      format.xml  { head :ok }
    end
  end
end
