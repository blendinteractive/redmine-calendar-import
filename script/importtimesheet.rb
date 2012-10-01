require 'rubygems' # Unless you install from the tarball or zip.
basepath = File.dirname(__FILE__) + '/../../../../'
require basepath + 'config/boot'
require basepath + 'config/environment'
require 'icalendar'
require 'date'
require 'active_support'
require File.expand_path(File.dirname(__FILE__) + '/utilities.rb')
require File.expand_path(File.dirname(__FILE__) + '/calendar.rb')
require File.expand_path(File.dirname(__FILE__) + '/translateevent.rb')



notprinted = TRUE

# retrieve a list of the users that have 1 to many ics files to import
user_list = User.find(:all)


#delete from processed_results where date < 3 months ago
three_months_ago = 12.months.ago.to_datetime
cutoff_date = DateTime.new(2009,5,1) #when we make this live we will set this to 5/1/2009 so that we'll start from then
process_time = DateTime.now

make_archived(three_months_ago, 'date')

#TODO - do this the right way at some time
cutoff_date = cutoff_date + 4.hours

# ===> each user with an ICS file to import
user_list.each do |user|
    if user.user_calendars.any?    
        # ===> for each ics_file   
        user.user_calendars.each do |calendar_object|
            calendar_read = TRUE
            
            #remove all entries using different ics files for this user from the processed_results table
            make_archived(calendar_object.id, 'calendar_id')

            ics_file = calendar_object.ics_file
            http_user = calendar_object.http_user
            http_password = calendar_object.http_password
            # ===> if calendar opens
            # initialize your calendar
            
            begin
                found=FALSE
                attempts=0

                #try three times to open the file and wait a minute between each attempt.
                begin 
                    attempts+=1
                    cal_file = open(ics_file, :http_basic_authentication=>[http_user, http_password]).read
                rescue Exception => e
                    #this is just so we don't wait the extra minute if it's failed for the third time.
                    if attempts<3
                        sleep(60)
                    else 
                        raise
                    end
                else
                    found=TRUE
            end while (!found&&attempts<3)

            cals = Icalendar.parse(cal_file)
            calendar = cals.first
            if calendar
                # ===> each event in the calendar in last three months
                # Go through each event
                calendar.events.each do |event|
                    # only translate the event if it has completed already
                    if event.dtend < process_time && event.dtstart.end_of_day > three_months_ago.beginning_of_day && event.dtstart > cutoff_date
                        #use the current data to either add or edit a time entry from an event
                        begin
                            translate_event(event, user.id, calendar_object.id)
                        rescue Exception => e
                            debug('Error translating event: '+ e.to_s, __LINE__, __FILE__)
                        end
                    end
                end
                # <=== each event in the calendar 
            end
            # <=== if calendar opens
            rescue Exception => e
                print "Error parsing calendar \"", ics_file, "\":\n" , e, "\n\n"
                calendar_object.last_result = e.to_s
                calendar_object.last_processed_at = DateTime.now
                calendar_object.save
                calendar_read = FALSE
            else
                calendar_object.last_result = "Success"
                calendar_object.last_processed_at = DateTime.now
                calendar_object.save
            end

            begin
                if calendar_read
                    remove_entries(user.id, calendar_object.id)
                end
            rescue Exception => e
                debug('Error removing entries: '+ e.to_s, __LINE__, __FILE__)
            end
        end
        # <=== for each calendar_object     
    end
end
# <=== each user with an ICS file to import
