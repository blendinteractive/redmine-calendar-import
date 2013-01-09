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

require 'digest/md5'
require 'yaml'
TIMEZONE = "Central Time (US & Canada)"

def process_event_issue_list(calendar_id, description, end_date, event_guid, event_issue_list, minutes, project_name, start_date, user_id)
  minute_hash={}
  issue_hash={}
  error_hash={}

  if event_issue_list
    if event_issue_list.size > 0
      begin
        issue_hash, error_hash=split_issue_description(event_issue_list)
        if error_hash != {}
          error_hash.each do |issue_id, create_issue_error|
            log_error_list(user_id, calendar_id, event_guid, start_date, end_date, issue_id, [], project_name, description, create_issue_error)
          end
        end
      rescue Exception => e
        debug('Error caught splitting the issue description: '+ e.to_s, __LINE__, __FILE__)
      end

      begin
        minute_hash=assign_minutes(issue_hash, minutes)
      rescue Exception => e
        debug('Error caught assigning minutes: '+ e.to_s, __LINE__, __FILE__)
      end

    end
  end
  return issue_hash, minute_hash
end

def process_skipped_entries(calendar_id, description, end_date, event_guid, issue_hash, project_name, skipped_entries, start_date, user_id)
  if skipped_entries != '' or issue_hash.empty?
    begin
      if skipped_entries == ''
        skipped_entries = '[the entire event, due to no valid entries appearing in the event]'
      end
      create_skipped_entry(skipped_entries, user_id, calendar_id, event_guid, start_date, end_date, project_name, description)
    rescue Exception => e
      debug('Error creating a skipped entry: '+ e.to_s, __LINE__, __FILE__)
    end
  end
end

#################################################################
# Translate Event
#
# Takes in the passed in relavent information on the event and decides
# what to do with the event.
#
# Step 1.   Split the event into a list of issues
#
# Step 2.   Verify that there aren't any errors with the issue entered
#
# Step 3.   Enter a new error or a new time entry, depending on result 
#           of verification
#
#################################################################

def translate_event(event, user_id, calendar_id)
    project_name = event.summary.strip
    minutes = (event.dtend.strftime('%s').to_i - event.dtstart.strftime('%s').to_i)/60
    start_date = update_time(event.dtstart, TIMEZONE)
    end_date = update_time(event.dtend, TIMEZONE)
    description = event.description
    event_guid = Digest::MD5.hexdigest(event.uid+event.sequence.to_s)
    skipped_entries = ''
    
    
    #break the string on the # symbol !!IMPORTANT - leave the # on the front for later (may have to make my own function)
    begin
        event_issue_list, skipped_entries = return_issues(description)
    rescue Exception => e
        debug('Error getting an issue list: '+ e.to_s, __LINE__, __FILE__)
    end

    issue_hash, minute_hash = process_event_issue_list(calendar_id, description, end_date, event_guid, event_issue_list, minutes, project_name, start_date, user_id)
    process_skipped_entries(calendar_id, description, end_date, event_guid, issue_hash, project_name, skipped_entries, start_date, user_id)

    begin
    
        # ===> spin through the event issues and figure out what to do with them
        issue_hash.each do |issue_id, issue_description|

            
            error_id_list=[]
            returned_issue_id=NIL
            minutes_assigned = minute_hash[issue_id]

            # ===> check to see if it's valid
            ####################################################
            #
            # Once I actually build out the error screen on the user side
            # I should take the issue_id that had a problem and use highlighting (and perhaps hover text)
            # to display what error you have with the specific issue_id
            #
            ####################################################

            
            error_id_list = get_error_value(user_id, project_name, issue_id, issue_hash, event_guid, event.recurrence_rules) #should return 0 (or empty array) if no error, otherwise the array of error_ids

            if error_id_list != [] 
                begin 
                  log_error_list(user_id, calendar_id, event_guid, start_date, end_date, issue_id, error_id_list, project_name, description, 0)
                rescue Exception => e
                    debug('Error logging an error list: '+ e.to_s, __LINE__, __FILE__)
                end
            else
                
                
                # if this is a new issue, we need to create the issue before we assign time to it.
                if !(issue_id =~ /^[0-9]+$/)
                    found_issue_id = NIL
                    project_id = get_project_id(user_id, project_name, event_guid)
                    found_issue_id = find_issue(issue_id, project_id)

                    if found_issue_id
                        returned_issue_id = found_issue_id
                    else
                        actual_title = issue_id
                        #this will return the issue_id of the issue it creates.  Unless there is an error when trying to create the issue.
                        #then it will return the error_id with a - symbol in front (so that I know it's an error and not a issue_id)
                        begin
                          puts "Skipping create_issue(#{user_id},#{project_id},#{actual_title},#{issue_description}):#{returned_issue_id}:#{returned_issue_id == nil}"
                          returned_issue_id = -1
                          #returned_issue_id = create_issue(user_id, project_id, actual_title, issue_description)
                        rescue Exception => e
                            puts 'user_id:'+user_id.to_s
                            puts 'project_id:'+project_id.to_s
                            puts 'actual_title:'+actual_title.to_s
                            puts 'issue_description:'+issue_description.to_s
                            debug('Error creating a new issue: '+ e.to_s, __LINE__, __FILE__)
                        end
                    end
                    
                    if (returned_issue_id < 0)
                        #we already know it's not valid because it threw an error in the create_issue() function
                        begin
                          puts "Skipping issue creation but logging"
                          log_error_list(user_id, calendar_id, event_guid, start_date, end_date, issue_id, error_id_list, project_name, description, returned_issue_id*-1)
                        rescue Exception => e
                            debug('Error logging an error list for a newly created issue '+issue_description+': '+ e.to_s, __LINE__, __FILE__)
                        end
                    else
                        begin
                          log_time_entry(user_id, calendar_id, event_guid, minutes_assigned, returned_issue_id, issue_description, project_id, start_date)
                        rescue Exception => e
                            debug('Error loggin a time entry for a newly created issue: '+ e.to_s, __LINE__, __FILE__)
                        end  
                    end
                    

                else
                    begin
                      log_time_entry(user_id, calendar_id, event_guid, minutes_assigned, issue_id, issue_description, project_id, start_date)
                    rescue Exception => e
                        debug('Error logging a time entry: '+ e.to_s, __LINE__, __FILE__)
                    end                 
                end

               
            end

          
            count=+1

        end
        # <=== spin through the event issues and figure out what to do with them

    rescue Exception => e
        debug('Error evaluating the issue hash: '+ e.to_s, __LINE__, __FILE__)
    end
end   

#################################################################
# Find Issue
# 
# Search through the issues to see if we can find
# whether or not the issue was created already
# (this replaces the need for Find Script Created Issue now with the new syntax
#
#################################################################

def find_issue(issue_id, project_id)
    return_value = NIL
    #search through the issues table to see if we can find this issue subject
    issue = Issue.find(:first, :conditions=>{:subject => issue_id, :project_id => project_id})
    if issue
        return_value = issue.id
    end
    return_value
end


#################################################################
# Find Script Created Issue
# 
# Search through the script_created_issues to see if we can find
# whether or not the issue was created already (in a previous pass
#
#################################################################

def find_script_created_issue(user_id, calendar_id, event_guid, issue_id, project_id)
    return_value = NIL
    #search through the script_created_issues table to see if we can find this issue id
    issue = ScriptCreatedIssue.find(:first, :conditions=>{:user_id => user_id, :user_calendar_id => calendar_id, :event_guid => event_guid, :new_issue_id => issue_id, :project_id => project_id})
    if issue
        return_value = issue.issue_id
    end
    return_value
end


#################################################################
# Split Issue Description
#
# At this point we know that everything we get is an issue, we just
# need to split them up into issue_id and issue_description in a hash.
#
# This also handles a list of new issues marked #* by replacing the *
# with *new[number] where number is a counter making each issue distinct
#
#################################################################

def split_issue_description(issue_list)
    issue_array = []
    issue_hash = {}
    count=0
    error_hash = {}

    for issue in issue_list
        #instead of separating on space, we are separating on a - or :
        #issue_array=issue.scan(/#[ ]?([0-9*]*)(.*)/m)
        if issue.include?("-")
            issue_array=issue.scan(/#([^-]*)[-](.*)$/m)
            issue_hash [issue_array[0][0].strip] = issue_array[0][1].lstrip
        else
            error_hash[issue]=10 #There was an error trying to seperate out your title or ID from the description.
        end
    end

    return issue_hash, error_hash
end


#################################################################
# Return Issues
#
# Go through each line of the description.  Once an issue has been
# found, start building out a issue_line.  This can continue on for many
# lines.
#
# When a new issue has been found, assign all of the issue_line to the
# issues array and then assign the new line to the issue_line
#
# Finally, if an issue was started, assign the last issue_line to the
# issues array and return the issues array.
#
#################################################################

def return_issues(description)
    issues = Array.new
    new_issue = FALSE 
    issues_started = FALSE 
    issue_line = ''
    skipped_entry = ''

    
    if description
        description.each do |line|
            if line.starts_with?('#')
                new_issue= TRUE
                issues_started = TRUE
            end

            if issues_started
                if new_issue && issue_line != ''
                    
                    # put the line into the array of issues
                    issues << issue_line
                    issue_line = ''
                end
                new_issue = FALSE
                issue_line = issue_line + line 
            else
               skipped_entry = skipped_entry + line
            end
        end
    end    

    # if the issues were started append the last line
    if issues_started
       issues << issue_line
    end

    return issues, skipped_entry #just need to remember to put the variable as the last line to return it
end


#################################################################
# Create Issue
#
# Create an issue under the correct project.  Assign the issue a
# title and a description from the issue_description variable.
#
# Returns: issue_id
#
#################################################################

def create_issue(user_id, project_id, title, description)
    return_value = NIL
    #lock_version = 0, priority_id = 12, status_id = 1, tracker_id = 1

    user = User.find(user_id)

    project = Project.find(project_id)
    
    issue_tracker = project.trackers.find(:first)
    if issue_tracker.nil?
      return_value << -5 #No tracker is associated to this project. Please check the Project settings.
    end

    default_status = IssueStatus.default
    unless default_status
      return_value << -6 #No default issue status is defined. Please check your configuration (Go to "Administration -> Issue statuses").
    end    
   
    #allowed_statuses = ([default_status] + default_status.find_new_statuses_allowed_to(User.current.role_for_project(project), issue_tracker)).uniq
    #requested_status = (params[:issue] && params[:issue][:status_id] ? IssueStatus.find_by_id(params[:issue][:status_id]) : default_status)
    # Check that the user is allowed to apply the requested status
    #issue_status = (allowed_statuses.include? requested_status) ? requested_status : default_status

    #priorities = Enumeration::get_values('IPRI')
    priorities = IssuePriority.all

    

    if return_value.nil? #no errors, continue on

        issue = Issue.new
        issue.tracker = issue_tracker
        issue.project_id = project_id
        issue.subject = title
        issue.description = description
        issue.status_id = default_status
        #issue.assigned_to_id = user_id
        issue.priority_id = priorities[0].id
        issue.author_id = user_id
        issue.lock_version = 0
        begin
            saved_properly = issue.save
            if !saved_properly
                puts issue_tracker.inspect
                puts 'issue_tracker: '+issue_tracker.to_s
                puts 'project_id: '+project_id.to_s
                puts 'title: '+title.to_s
                puts 'description: '+description.to_s
                puts 'default_status: '+default_status.to_s
                puts 'user_id: '+user_id.to_s
                puts 'priorities[0].id: '+priorities[0].id.to_s
                puts 'priorities[0]: '+priorities[0].to_s
                
                debug('there was an error saving the new Issue',__LINE__,__FILE__)
            end
        rescue Exception => e
            debug('Error saving a new issue: '+ e.to_s, __LINE__, __FILE__)
        end

        return_value = issue.id

    end
    return_value
end



#################################################################
# Log Error List
#
# Insert a new row (for each error_id in error_id_list) into the event_to_issue_errors table.  This is to
# keep track of the errors that will eventually be displayed back to
# the user in order for them to correct on their own.
#
# This also throws an error if there was an error on the create
#
#################################################################

def log_error_list(user_id, calendar_id, event_guid, start_date, end_date, issue_id, error_id_list, summary, description, create_issue_error)

    #if there was an issue creating the issue
    if create_issue_error > 0
        create_error(user_id, calendar_id, event_guid, start_date, end_date, issue_id, create_issue_error, summary, description)
    else
        #insert all of the above into the event_to_issue_errors table
        for error_id in error_id_list
            create_error(user_id, calendar_id, event_guid, start_date, end_date, issue_id, error_id, summary, description)       
        end
    end


end

def update_time(time, zone_name)
  zone = ActiveSupport::TimeZone.new(zone_name)
  time.in_time_zone(zone).time
end

#################################################################
# Create Error
#
# This actually creates the error specified
#
#################################################################

def create_error(user_id, calendar_id, event_guid, start_date, end_date, issue_id, error_id, summary, description)
    event_to_issue_error = EventToIssueError.find(:first, :conditions=>{:user_id=>user_id, :event_guid=>event_guid, :issue_id=>issue_id, :error_id=>error_id})
    event_to_issue_error_id = 0

    if event_to_issue_error
        
        event_to_issue_error.start_date = start_date
        event_to_issue_error.end_date = end_date
        event_to_issue_error.issue_id = issue_id
        event_to_issue_error.error_id = error_id
        event_to_issue_error.summary = summary
        event_to_issue_error.description = description

        saved_properly = event_to_issue_error.save

        unless saved_properly
            puts "Event to issue error save: #{event_to_issue_error.save}"
            puts "saved_properly: #{saved_properly}"
            debug('there was an error saving the EventToIssueError',__LINE__,__FILE__)
        end
        
        event_to_issue_error_id = event_to_issue_error.id
    else
        event_to_issue_error = EventToIssueError.new

        event_to_issue_error.user_id = user_id
        event_to_issue_error.calendar_id = calendar_id
        event_to_issue_error.event_guid = event_guid
        event_to_issue_error.start_date = start_date
        event_to_issue_error.end_date = end_date
        event_to_issue_error.issue_id = issue_id
        event_to_issue_error.error_id = error_id
        event_to_issue_error.summary = summary
        event_to_issue_error.description = description

        saved_properly = event_to_issue_error.save

        unless saved_properly
            debug('there was an error saving the new EventToIssueError',__LINE__,__FILE__)
        else
            event_to_issue_error_id = event_to_issue_error.id
        end
    end
        
    process_result(user_id, calendar_id, 0, 0, event_to_issue_error_id)
end


#################################################################
# Create Skipped Entry
#
# This creates the skipped entry so that the user can know what items weren't processed
# in case they wanted it to be processed
#
#################################################################

def create_skipped_entry(skipped_entries, user_id, calendar_id, event_guid, start_date, end_date, summary, description)
    skipped_entry_id = 0
    skipped_entry = SkippedEntry.find(:first, :conditions=>{:user_id=>user_id, :event_guid=>event_guid})

    if skipped_entry
        skipped_entry.start_date = start_date
        skipped_entry.end_date = end_date
        skipped_entry.summary = summary
        skipped_entry.description = description
        skipped_entry.skipped_text = skipped_entries

        saved_properly = skipped_entry.save

        unless saved_properly
            debug('there was an error saving the new TimeEntry',__LINE__,__FILE__)
        end
        
        skipped_entry_id = skipped_entry.id
    else
        skipped_entry = SkippedEntry.new
        skipped_entry.user_id = user_id
        skipped_entry.calendar_id = calendar_id
        skipped_entry.event_guid = event_guid
        skipped_entry.start_date = start_date
        skipped_entry.end_date = end_date
        skipped_entry.summary = summary
        skipped_entry.description = description
        skipped_entry.skipped_text = skipped_entries

        saved_properly = skipped_entry.save

        unless saved_properly
            debug('there was an error saving the new SkippedEntry',__LINE__,__FILE__)
        end
        skipped_entry_id = skipped_entry.id
    end 
    
    process_result(user_id, calendar_id, 0, skipped_entry_id, 0)
end


#################################################################
# Assign Minutes
#
# For now we will just add up how many issue_ids are placed in the 
# description and divide the minutes by that, rounding up to 15 minutes.
# 
# For future releases we will assign minutes according to the ammount
# specified per issue_id and the remaining (that weren't assigned a
# specific amount) will have their amount calculated from the remaining
# time that isn't assigned.
#
# Step 1.   Run through the list of possible event issues and count up
#           how the time should be divided between the issues.
#
# Step 2.   Assign the minutes (rounded up to 15 minute increments)
#           (a 1 hour event, with 3 issues will end up assigning 1.5 
#           hours of time. .33 rounded up to .5)
#
#################################################################

def assign_minutes(issue_hash, minutes)
    divided_by = issue_hash.size
    minute_hash = {}

    #division by zero is a bad thing
    if divided_by > 0
        issue_hash.each do |issue_id,description|
            #Run this regex
            
            minute_hash[issue_id] = round_to_15_minutes(minutes/divided_by)
        end
    end
    minute_hash
end


#################################################################
# Log Time Entry
# 
# Edit or Add a time entry according to what is passed in.
#
# Step 1.   Check to see if the user_id, event_guid, and issue_id was
#           done in the time_entry table before (then edit) or if it is new (then add)
#
# Step 2.   After adding or editing, take the time_entry_id that was
#           filled in during the previous step and process that result by either
#           editing or adding it to the processed_results table.  (so that we know
#           that the time was processed and the time_entry doesn't need to be deleted)
#
#################################################################

# Add or edit a time entry 
def log_time_entry(user_id, calendar_id, event_guid, minutes_assigned, issue_id, issue_description, project_id, spent_on)
    hours_assigned = 0.0
    hours_assigned = minutes_assigned / 60.0

    time_entry = TimeEntry.find(:first, :conditions=>{:user_id=>user_id, :event_guid=>event_guid, :issue_id=>issue_id})

    if time_entry
        time_entry_date = spent_on
        time_entry.spent_on = spent_on
        time_entry.tyear = time_entry_date.year
        time_entry.tmonth = time_entry_date.month
        time_entry.tweek = time_entry_date.to_date.cweek
        time_entry.hours = hours_assigned
        time_entry.comments = issue_description[0..254]

        saved_properly = time_entry.save

        unless saved_properly
            puts time_entry.to_yaml
            debug('there was an error saving the TimeEntry',__LINE__,__FILE__)
        end

        time_entry_id = time_entry.id

    else
        time_entry = TimeEntry.new

	      activities = TimeEntryActivity.all
        time_entry_date = spent_on

        time_entry.project_id = project_id
        time_entry.user_id = user_id
        time_entry.issue_id = issue_id
        time_entry.hours = hours_assigned
        time_entry.comments = issue_description[0..254]
        time_entry.activity_id = activities[0].id
        time_entry.spent_on = spent_on
        time_entry.tyear = time_entry_date.year
        time_entry.tmonth = time_entry_date.month
        time_entry.tweek = time_entry_date.to_date.cweek
        time_entry.event_guid = event_guid

        saved_properly = time_entry.save

        if !saved_properly
            puts time_entry.inspect
            debug('there was an error saving the new TimeEntry',__LINE__,__FILE__)
        end
        time_entry_id = time_entry.id
        
    end

    process_result(user_id, calendar_id, time_entry_id, 0, 0)
end



#################################################################
# Get Error Value
#
# Return a list of errors that are related to the event on the calendar
#
# Step 1.   Return any errors relating to the project name (most likely
#           that the project doesn't exist)
#
# Step 2.   Return any errors relating to the issue_id
#
# Return a list of error id's
# 
#################################################################

def get_error_value(user_id, project_name, issue_id, issue_hash, event_guid, rrule) #should return 0 if no error, otherwise the error id

    error_id_list = []

    # ===> foreach error, insert the error into the array
    project_name_errors(user_id, project_name, event_guid).each do |error_id|
        error_id_list << error_id
    end
    # <=== foreach error, insert the error into the array
    if rrule != []
        error_id_list << 9 #You are not allowed to save reoccurring issues in your timesheet for Redmine. 
    elsif !(issue_id =~ /^[0-9]+$/) #instead of checking for a '*' we are now checking to see if it has more than just #'s
        #make sure two identical issue's weren't created under the same event
        check_for_originality(issue_id, issue_hash).each do |error_id|
            error_id_list << error_id
        end 
    else
        #make sure two identical issue's weren't created under the same event
        check_for_originality(issue_id, issue_hash).each do |error_id|
            error_id_list << error_id
        end 
        # ===> foreach error, insert the error into the array
        event_issue_errors(user_id, project_name, issue_id, event_guid, error_id_list).each do |error_id|
            error_id_list << error_id
        end
        # <=== foreach error, insert the error into the array
    end

    error_id_list
end


#################################################################
# Check For Proper Title
#
# Looks to see if the correct title was placed on the new item
#
#################################################################

def check_for_proper_title(id_searching_for, issue_hash)
    found = FALSE
    error_list = []

    issue_description = issue_hash[id_searching_for]

    actual_title=''
    actual_description=''
    title_description_array=issue_description.scan(/^([^-]*)[-](.*)$/)

    unless title_description_array[0].nil?
        found = TRUE
    end   
       
    if !found
        error_list << 7 #There isn't a properly formed title for creating a new issue.
    end
    error_list
end


#################################################################
# Check For Originality
#
# Looks to see if all of the "new" issues that were created in the 
# event with a #* were given unique identifiers
#
#################################################################

def check_for_originality(id_searching_for, issue_hash)
    found = 0
    error_list = []
    name_searching_for = ''

    #we first need to take off the word 'new' and everything afterwards (because that's what this script adds)
    #match = id_searching_for.match('new')
    #id_searching_for = match.pre_match
    if id_searching_for =~ /^[0-9]+$/
        begin 
            issue = Issue.find(id_searching_for)
        rescue
            name_searching_for = ''
        else
            unless issue.nil?
                name_searching_for = issue.subject
            end
        end
        
    end
    issue_hash.each do |issue_id, issue_description|
        # referencing id's by ID number
        if id_searching_for == issue_id
            found=found+1
        # referencing id's by name
        elsif name_searching_for == issue_id
            found=found+1
        end        
    end    
    if found > 1
        error_list << 4 #This issue is referenced twice in the same event.
    end
    error_list
end


#################################################################
# Event Issue Errors
#
# Return a list of errors that are related to the specific issue_id
# passed in.
#
# Step 1.   Check to see if the issue_id is formed correctly (#123a
#           is not properly formed, due to the 'a'.  Integers only.
#
# Step 2.   Check to see if the issue_id is a child of that project.
#           This is mainly to keep people from fat fingering the 
#           issue_id.  The issue_id's are completely independent from
#           the project, so mapping these two together is a good way
#           to keep time from being accidentally assigned to the wrong project
#
# Return: an issue_id or nothing
#
#################################################################
def event_issue_errors(user_id, project_name, issue_id, event_guid, current_error_list)
    error_list = []
    project_id = get_project_id(user_id, project_name, event_guid)

    if project_id           
        issue = Issue.find_by_id(issue_id)
        unless issue.nil?
            unless current_error_list.include?(1)
                if issue.project_id != project_id
                    error_list << 3 #The issue id is not in the project specified.
                end
            end
        else
            error_list << 8 #The issue id is not a valid issue id in the system even though it was formed correctly. 
        end                
    end
    error_list
end


#################################################################
# Project Name Errors
#
# Return a list of errors that are related to the specific project_name
# passed in.
#
# Currently it just checks to make sure the project name given is
# actually a valid project
#
# Return: an issue_id or nothing
#
#################################################################

def project_name_errors(user_id, project_name, event_guid)
    error_list = []
    project_id = get_project_id(user_id, project_name, event_guid)
    
    # ===> not a valid project name
    if project_id == 0
        error_list << 1 #This isn't a valid project name and you haven't set up an alias for it yet.
    end
    # <=== not a valid project name

    error_list
end


#################################################################
# Get Project ID
#
# Checks for a valid project_id for the given project_name
#
# Step 1.   Check to see if the user has created a project alias
#           for the given project name
#
# Step 2.   If a project alias wasn't assigned for that name, check
#           to see if that is the name of a valid project
#
# Return: a project_id (which is '' if none found)
#
#################################################################

def get_project_id(user_id, project_name, event_guid)
    project_id=0
    project_alias = UserToProjectMapping.find(:first, :conditions=>{:project_alias=>project_name, :event_guid=>event_guid, :user_id=>user_id})
    
    if project_alias
        project_id = project_alias.project_id
    end
    # ===> if that has a value, we know that we have a project alias for that project for this specific event_guid and there should be no reason to look into this project name any further, as we know that it is valid now
    if project_id == 0
        project_alias = UserToProjectMapping.find(:first, :conditions=>{:project_alias=>project_name, :event_guid=>'', :user_id=>user_id})
        
        if project_alias
            project_id = project_alias.project_id
        end
    end
    # ===> if that has a value, we know that we have a project alias for that project and there should be no reason to look into this project name any further, as we know that it is valid now
    if project_id == 0
        project = Project.find(:first, :conditions=>{:name => project_name})
        if project
            project_id = project.id
        end
    end
    # <=== if that has a value, we know...
    project_id
end
