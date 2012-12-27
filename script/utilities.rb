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

#################################################################
# Debug
#
# prints out the message and the line number passed in
#
#################################################################

def debug(message, line_number, file_name)

    puts message+' caught on line #'+line_number.to_s+' of '+file_name
    puts ''
    
    #logfile   = File.open(File.dirname(__FILE__).to_s+'../log/importtimesheet_log.txt', File::WRONLY|File::APPEND|File::CREAT) 

    
    #old = $defout
    #$defout = logfile                 # switch to logfile for output
    #puts message+' on line #'+line_number.to_s+' of '+file_name
    #$defout = old                     # return to original output

end


#################################################################
# todo
#
# prints out the message and the line number passed in and adds todo at the beginning
#
#################################################################

def todo(message, line_number, file_name)

    message='TODO:: '+message
    debug(message,line_number, file_name)
end



#################################################################
# Starts With?
#
# Returns true or false depending on whether the object that sent
# this call starts with the variable passed in.
#
#################################################################

def starts_with?(prefix)
    prefix = prefix.to_s
    self[0, prefix.length] == prefix
end 


#################################################################
# Make Archived
#
# If no ics files are passed in, it will delete all entries in the 
# processed_results table that are older than 3 months ago (using the
# date passed in through the calendar_id_processed_time variable)
#
# Otherwise, it will take the ics files passed in and delete all entries 
# from the processed_results table for the user_id passed in (in the calendar_id_processed_time variable)
# and the ics files passed in
#################################################################


def make_archived(calendar_id_processed_time, type)

    if type == 'calendar_id'
                    
        #set all of these to zero because they removed their calendar and so everything that isn't too old will be deleted at the end
        # or they will be set as processed if they are still there
        processed_result_list = ProcessedResult.find(:all, :conditions=>["user_calendar_id = #{calendar_id_processed_time} "])
        for processed_result in processed_result_list
            processed_result.processed = 0
            saved_properly = processed_result.save
            
            if !saved_properly
                debug('there was an error saving the ProcessedResult',__LINE__,__FILE__)
            end

        end
    else
        #delete from processed_results where date < 3 months ago
        processed_result_list = ProcessedResult.find(:all, :conditions=>["created_at < '#{calendar_id_processed_time}'"])
        for processed_result in processed_result_list
            
            #we delete the processed result if it's an old time entry (because we want to save the time entries) otherwise we set
            # it to zero so that they all get deleted at the end
            #if !processed_result.time_entry_id.nil?
                result = processed_result.destroy
                if !result
                    debug('Processed result '+processed_result.id.to_s+' was not deleted properly',__LINE__,__FILE__)
                end
            #else
            #    processed_result.processed = 0
            #    saved_properly = processed_result.save
                
            #    if !saved_properly
            #        debug('there was an error saving the ProcessedResult',__LINE__,__FILE__)
            #    end
            #end
        
        end
    end
end


#################################################################
# Remove Entries
#
# This will remove all entries from the time_entries, skipped_entries, or event_to_issue_errors table if their related entry
# is not marked as "Processed" in the processed_results table and they are in one of
# the ics files listed for this person
#
#################################################################

def remove_entries(user_id, user_calendar_id)
    
 
    #get a list of all time entries that should be removed from the time_entry table.
    #select time_entry from processed_results where user_id = user_id and processed_results.processed = 0
    processed_result_list = ProcessedResult.find(:all, :conditions=>{:user_id=>user_id, :user_calendar_id=>user_calendar_id, :processed=>0})

    if processed_result_list
        #delete the time entries
        for processed_result in processed_result_list
            entry = NIL
            found_where = ''
            if !processed_result.time_entry_id.nil?
                entry = TimeEntry.find_by_id(processed_result.time_entry_id)
                found_where='time entry'
            elsif !processed_result.event_to_issue_error_id.nil?
                entry = EventToIssueError.find_by_id(processed_result.event_to_issue_error_id)
                found_where='EventToIssueError'
            elsif !processed_result.skipped_entry_id.nil?
                entry = SkippedEntry.find_by_id(processed_result.skipped_entry_id)
                found_where='skipped entry'
            end
            unless entry.nil?
                result = entry.destroy() 
                
                if !result
                    debug('there was an error deleting an item listed in processed results ',__LINE__,__FILE__)
                end
            else
                    puts 'User ID: '+user_id.to_s
                    puts 'Found Where: '+found_where.to_s
                    debug('there was an error deleting an item listed in processed results ',__LINE__,__FILE__)                
            end
            #delete from entry where id in (results)
            if result #delete worked
                #remove the items from the processed_results table then, if they are deleted from the time_entry table.
                result = processed_result.destroy
                if !result
                    debug('Processed result '+processed_result.id.to_s+' was not deleted properly',__LINE__,__FILE__)
                end
            end
       end
    end
end




#################################################################
# Round To 15 Minutes
#
# Round the number passed in to a number divisible by .25
# 
# a 1 hour event, with 3 issues will end up assigning 1.5 hours of time.
# .33 rounded up to .5
#
# Return: minutes (rounded)
#
#################################################################

def round_to_15_minutes(minutes)
    minutes + (15 - (minutes % 15))
end



#################################################################
# Unprocess Results
# 
# This goes through all of the entries in processed_results and sets
# their processed flag to 0 (not processed)
#
# This is done at the beginning of every run on a list of ics files
# for everything
#
#################################################################
def unprocess_results()

    
    processed_result_list = ProcessedResult.find(:all)
    for processed_result in processed_result_list
        processed_result.processed = 0
        saved_properly = processed_result.save
        
        if !saved_properly
            debug('there was an error saving the ProcessedResult',__LINE__,__FILE__)
        end
    end
end



#################################################################
# Remove Errors
# 
# This goes through all of the errrors in event_to_issue_errors and deletes them
#
# This is done at the beginning of every run on a user, so that by the end of the 
# process we know which event_to_issue_errors are current
#
#################################################################
#def remove_errors(user_id)

#    event_to_issue_error_list = EventToIssueError.find(:all, :conditions=>{:user_id=>user_id})
#    for event_to_issue_error in event_to_issue_error_list
#        result = event_to_issue_error.destroy
#        if !result
#            debug('Event to issue error '+event_to_issue_error.id.to_s+' was not deleted properly',__LINE__,__FILE__)
#        end
#    end
#end


#################################################################
# Process Results
#
# Either adds a new entry or edits an old entry.  This lets us know
# that a time_entry was created for an event/issue on the calendar.
#
# We use this infomration at the end of the run of ics files for a
# user, so that we know what time_entries need to be deleted because
# they are no longer valid due to their event on the calendar being
# deleted, or their issue in an event being removed.
# 
#################################################################

def process_result(user_id, calendar_id, time_entry_id, skipped_entry_id, event_to_issue_error_id)
    processed_result = NIL
    if time_entry_id != 0
        processed_result = ProcessedResult.find(:first, :conditions=>{:time_entry_id=>time_entry_id})
        if processed_result
            processed_result.processed = 1
            
            saved_properly = processed_result.save
            
            if !saved_properly
                debug('there was an error saving the new ProcessedResult',__LINE__,__FILE__)
            end
        else
            processed_result = ProcessedResult.new
            processed_result.processed = 1
            processed_result.user_id = user_id
            processed_result.time_entry_id = time_entry_id
            processed_result.user_calendar_id = calendar_id
            
            saved_properly = processed_result.save
            
            if !saved_properly
                debug('there was an error saving the new ProcessedResult',__LINE__,__FILE__)
            end
        end
    elsif skipped_entry_id != 0

        processed_result = ProcessedResult.find(:first, :conditions=>{:skipped_entry_id=>skipped_entry_id})
        if processed_result
            processed_result.processed = 1
            
            saved_properly = processed_result.save
            
            if !saved_properly
                debug('there was an error saving the new ProcessedResult',__LINE__,__FILE__)
            end
        else
            processed_result = ProcessedResult.new
            processed_result.processed = 1
            processed_result.user_id = user_id
            processed_result.skipped_entry_id = skipped_entry_id
            processed_result.user_calendar_id = calendar_id
            
            saved_properly = processed_result.save
            
            if !saved_properly
                debug('there was an error saving the new ProcessedResult',__LINE__,__FILE__)
            end
        end
    elsif event_to_issue_error_id != 0

        processed_result = ProcessedResult.find(:first, :conditions=>{:event_to_issue_error_id=>event_to_issue_error_id})
        if processed_result
            processed_result.processed = 1
            
            saved_properly = processed_result.save
            
            if !saved_properly
                debug('there was an error saving the new ProcessedResult',__LINE__,__FILE__)
            end
        else
            processed_result = ProcessedResult.new
            processed_result.processed = 1
            processed_result.user_id = user_id
            processed_result.event_to_issue_error_id = event_to_issue_error_id
            processed_result.user_calendar_id = calendar_id
            
            saved_properly = processed_result.save
            
            if !saved_properly
                debug('there was an error saving the new ProcessedResult',__LINE__,__FILE__)
            end
        end
    end
   
end

