class SkippedEntriesController < ApplicationController
  layout 'base'

  # GET /skipped_entries
  # GET /skipped_entries.xml
  def index
    @skipped_entries = SkippedEntry.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @skipped_entries }
    end
  end

  # GET /skipped_entries/1
  # GET /skipped_entries/1.xml
  def show
    @skipped_entry = SkippedEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @skipped_entry }
    end
  end

  # GET /skipped_entries/new
  # GET /skipped_entries/new.xml
  def new
    @skipped_entry = SkippedEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @skipped_entry }
    end
  end

  # GET /skipped_entries/1/edit
  def edit
    @skipped_entry = SkippedEntry.find(params[:id])
  end

  # POST /skipped_entries
  # POST /skipped_entries.xml
  def create
    @skipped_entry = SkippedEntry.new(params[:skipped_entry])

    respond_to do |format|
      if @skipped_entry.save
        flash[:notice] = 'SkippedEntry was successfully created.'
        format.html { redirect_to(@skipped_entry) }
        format.xml  { render :xml => @skipped_entry, :status => :created, :location => @skipped_entry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @skipped_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /skipped_entries/1
  # PUT /skipped_entries/1.xml
  def update
    @skipped_entry = SkippedEntry.find(params[:id])

    respond_to do |format|
      if @skipped_entry.update_attributes(params[:skipped_entry])
        flash[:notice] = 'SkippedEntry was successfully updated.'
        format.html { redirect_to(@skipped_entry) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @skipped_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /skipped_entries/1
  # DELETE /skipped_entries/1.xml
  def destroy
    @skipped_entry = SkippedEntry.find(params[:id])
    @skipped_entry.destroy

    respond_to do |format|
      format.html { redirect_to(skipped_entries_url) }
      format.xml  { head :ok }
    end
  end
end
