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

class UserToProjectMappingsController < ApplicationController
  unloadable
  layout 'base'

  # GET /user_to_project_mappings
  # GET /user_to_project_mappings.xml
  def index
    @user_to_project_mappings = UserToProjectMapping.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_to_project_mappings }
    end
  end

  # GET /user_to_project_mappings/1
  # GET /user_to_project_mappings/1.xml
  def show
    @user_to_project_mapping = UserToProjectMapping.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_to_project_mapping }
    end
  end

  # GET /user_to_project_mappings/new
  # GET /user_to_project_mappings/new.xml
  def new
    @projects = {}
    @projects_objects = Project.find(:all, :order=>"name")

    for @project_object in @projects_objects
        @projects[@project_object.name] = @project_object.id
    end
    
    @projects = @projects.sort()

    @user_to_project_mapping = UserToProjectMapping.new
    if params[:summary]
        @user_to_project_mapping.project_alias = params[:summary]
    end
    if params[:event_guid]
        @user_to_project_mapping.event_guid = params[:event_guid]
    end
    

    @user = User.current
    @user_to_project_mapping.user_id = @user.id

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_to_project_mapping }
    end
  end

  # GET /user_to_project_mappings/1/edit
  def edit
  
    @user_to_project_mapping = UserToProjectMapping.find(params[:id])
    
    if params[:event_guid]
        @user_to_project_mapping.event_guid = params[:event_guid]
    end

    @projects = Project.find(:all, :order=>"name")
    @selected_project = Project.find(@user_to_project_mapping.project_id).name


  end

  # POST /user_to_project_mappings
  # POST /user_to_project_mappings.xml
  def create
    @user_to_project_mapping = UserToProjectMapping.new(params[:user_to_project_mapping])

    if params[:use_alias] == 'for all time entries.'
        @user_to_project_mapping.event_guid = '';
    end

    @user_to_project_mapping.project_id = params[:project]
    respond_to do |format|
      if @user_to_project_mapping.save
        @name = @user_to_project_mapping.project_alias
        flash[:notice] = "The project alias '#{@name}' was successfully created."
        format.html { redirect_to(url_for :controller => "calendar_imports", :action => "index") }

      else
      
        @projects = {}
        @projects_objects = Project.find(:all, :order=>"name")

        for @project_object in @projects_objects
            @projects[@project_object.name] = @project_object.id
        end
        
        @projects = @projects.sort()
        format.html { render :action => "new", :event_guid => @user_to_project_mapping.event_guid, :summary => @user_to_project_mapping.project_alias }
        format.xml  { render :xml => @user_to_project_mapping.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_to_project_mappings/1
  # PUT /user_to_project_mappings/1.xml
  def update
    @user_to_project_mapping = UserToProjectMapping.find(params[:id])

    
    if params[:use_alias] == 'for all time entries.'
        @user_to_project_mapping.event_guid = '';
    end

    respond_to do |format|
      if @user_to_project_mapping.update_attributes(params[:user_to_project_mapping])
        flash[:notice] = "'#{@user_to_project_mapping.project_alias}' was successfully updated."
        format.html { redirect_to(url_for :controller => "calendar_imports", :action => "index") }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_to_project_mapping.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_to_project_mappings/1
  # DELETE /user_to_project_mappings/1.xml
  def destroy
    @user_to_project_mapping = UserToProjectMapping.find(params[:id])
    @name = @user_to_project_mapping.project_alias
    @user_to_project_mapping.destroy

    respond_to do |format|
      flash[:notice] = "The project alias '#{@name}' was successfully removed."
      format.html { redirect_to(url_for :controller => "calendar_imports", :action => "index") }
      format.xml  { head :ok }
    end
  end
end
