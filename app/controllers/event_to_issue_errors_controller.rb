class EventToIssueErrorsController < ApplicationController
  layout 'base'
  before_filter :require_admin
  skip_before_filter :require_admin, :only => [:show]

  # GET /event_to_issue_errors
  # GET /event_to_issue_errors.xml
  def index
    @event_to_issue_errors = EventToIssueError.find(:all,:conditions => ['start_date >  ?', 2.months.ago.to_datetime])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @event_to_issue_errors }
    end
  end

  # GET /event_to_issue_errors/1
  # GET /event_to_issue_errors/1.xml
  def show
    @event_to_issue_error = EventToIssueError.find(params[:id])
=begin
    description = @event_to_issue_error.description

    start_location = description.rindex(@event_to_issue_error.issue_id)
    start = description.slice(0,start_location)

    after_start = description.slice(start_location)
    end_location = after_start.rindex('<br/>#')
    if end_location == 0
        close = '<span style="color:#550000;">'+after_start+'</span>'
    else
        close = '<span style="color:#550000;">'+after_start.slice(0,end_location)+'</span>'+after_start.slice(end_location)
    end
    


    description = start+close

=end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event_to_issue_error }
    end
  end

  # GET /event_to_issue_errors/new
  # GET /event_to_issue_errors/new.xml
  def new
    @event_to_issue_error = EventToIssueError.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event_to_issue_error }
    end
  end

  # GET /event_to_issue_errors/1/edit
  def edit
    @event_to_issue_error = EventToIssueError.find(params[:id])
  end

  # POST /event_to_issue_errors
  # POST /event_to_issue_errors.xml
  def create
    @event_to_issue_error = EventToIssueError.new(params[:event_to_issue_error])

    respond_to do |format|
      if @event_to_issue_error.save
        flash[:notice] = 'EventToIssueError was successfully created.'
        format.html { redirect_to(@event_to_issue_error) }
        format.xml  { render :xml => @event_to_issue_error, :status => :created, :location => @event_to_issue_error }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event_to_issue_error.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /event_to_issue_errors/1
  # PUT /event_to_issue_errors/1.xml
  def update
    @event_to_issue_error = EventToIssueError.find(params[:id])

    respond_to do |format|
      if @event_to_issue_error.update_attributes(params[:event_to_issue_error])
        flash[:notice] = 'EventToIssueError was successfully updated.'
        format.html { redirect_to(@event_to_issue_error) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event_to_issue_error.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /event_to_issue_errors/1
  # DELETE /event_to_issue_errors/1.xml
  def destroy
    @event_to_issue_error = EventToIssueError.find(params[:id])
    @event_to_issue_error.destroy

    respond_to do |format|
      format.html { redirect_to(event_to_issue_errors_url) }
      format.xml  { head :ok }
    end
  end
end
