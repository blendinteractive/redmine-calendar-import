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

class ErrorsController < ApplicationController
  unloadable
  layout 'base'

  # GET /errors
  # GET /errors.xml
  def index
    @errors = Error.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @errors }
    end
  end

  # GET /errors/1
  # GET /errors/1.xml
  def show
    @error = Error.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @error }
    end
  end

  # GET /errors/new
  # GET /errors/new.xml
  def new
    @error = Error.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @error }
    end
  end

  # GET /errors/1/edit
  def edit
    @error = Error.find(params[:id])
  end

  # POST /errors
  # POST /errors.xml
  def create
    @error = Error.new(params[:error])

    respond_to do |format|
      if @error.save
        flash[:notice] = 'Error was successfully created.'
        format.html { redirect_to(@error) }
        format.xml  { render :xml => @error, :status => :created, :location => @error }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @error.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /errors/1
  # PUT /errors/1.xml
  def update
    @error = Error.find(params[:id])

    respond_to do |format|
      if @error.update_attributes(params[:error])
        flash[:notice] = 'Error was successfully updated.'
        format.html { redirect_to(@error) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @error.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /errors/1
  # DELETE /errors/1.xml
  def destroy
    @error = Error.find(params[:id])
    @error.destroy

    respond_to do |format|
      format.html { redirect_to(errors_url) }
      format.xml  { head :ok }
    end
  end
end
