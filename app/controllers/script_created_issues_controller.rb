class ScriptCreatedIssuesController < ApplicationController
  layout 'base'

  # GET /script_created_issues
  # GET /script_created_issues.xml
  def index
    @script_created_issues = ScriptCreatedIssue.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @script_created_issues }
    end
  end

  # GET /script_created_issues/1
  # GET /script_created_issues/1.xml
  def show
    @script_created_issue = ScriptCreatedIssue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @script_created_issue }
    end
  end

  # GET /script_created_issues/new
  # GET /script_created_issues/new.xml
  def new
    @script_created_issue = ScriptCreatedIssue.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @script_created_issue }
    end
  end

  # GET /script_created_issues/1/edit
  def edit
    @script_created_issue = ScriptCreatedIssue.find(params[:id])
  end

  # POST /script_created_issues
  # POST /script_created_issues.xml
  def create
    @script_created_issue = ScriptCreatedIssue.new(params[:script_created_issue])

    respond_to do |format|
      if @script_created_issue.save
        flash[:notice] = 'ScriptCreatedIssue was successfully created.'
        format.html { redirect_to(@script_created_issue) }
        format.xml  { render :xml => @script_created_issue, :status => :created, :location => @script_created_issue }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @script_created_issue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /script_created_issues/1
  # PUT /script_created_issues/1.xml
  def update
    @script_created_issue = ScriptCreatedIssue.find(params[:id])

    respond_to do |format|
      if @script_created_issue.update_attributes(params[:script_created_issue])
        flash[:notice] = 'ScriptCreatedIssue was successfully updated.'
        format.html { redirect_to(@script_created_issue) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @script_created_issue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /script_created_issues/1
  # DELETE /script_created_issues/1.xml
  def destroy
    @script_created_issue = ScriptCreatedIssue.find(params[:id])
    @script_created_issue.destroy

    respond_to do |format|
      format.html { redirect_to(script_created_issues_url) }
      format.xml  { head :ok }
    end
  end
end
