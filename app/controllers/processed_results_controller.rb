class ProcessedResultsController < ApplicationController
  layout 'base'

  # GET /processed_results
  # GET /processed_results.xml
  def index
    @processed_results = ProcessedResult.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @processed_results }
    end
  end

  # GET /processed_results/1
  # GET /processed_results/1.xml
  def show
    @processed_result = ProcessedResult.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @processed_result }
    end
  end

  # GET /processed_results/new
  # GET /processed_results/new.xml
  def new
    @processed_result = ProcessedResult.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @processed_result }
    end
  end

  # GET /processed_results/1/edit
  def edit
    @processed_result = ProcessedResult.find(params[:id])
  end

  # POST /processed_results
  # POST /processed_results.xml
  def create
    @processed_result = ProcessedResult.new(params[:processed_result])

    respond_to do |format|
      if @processed_result.save
        flash[:notice] = 'ProcessedResult was successfully created.'
        format.html { redirect_to(@processed_result) }
        format.xml  { render :xml => @processed_result, :status => :created, :location => @processed_result }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @processed_result.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /processed_results/1
  # PUT /processed_results/1.xml
  def update
    @processed_result = ProcessedResult.find(params[:id])

    respond_to do |format|
      if @processed_result.update_attributes(params[:processed_result])
        flash[:notice] = 'ProcessedResult was successfully updated.'
        format.html { redirect_to(@processed_result) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @processed_result.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /processed_results/1
  # DELETE /processed_results/1.xml
  def destroy
    @processed_result = ProcessedResult.find(params[:id])
    @processed_result.destroy

    respond_to do |format|
      format.html { redirect_to(processed_results_url) }
      format.xml  { head :ok }
    end
  end
end
