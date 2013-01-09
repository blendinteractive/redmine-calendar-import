module ImportProcessor
    require 'icalendar'
    require 'open-uri'
    require File.expand_path(File.dirname(__FILE__) + '/open_uri.rb')
    require 'uri'
    require File.expand_path(File.dirname(__FILE__) + '/../script/utilities.rb')
    require File.expand_path(File.dirname(__FILE__) + '/../script/calendar.rb')
    require File.expand_path(File.dirname(__FILE__) + '/../script/translateevent.rb')
    require File.expand_path(File.dirname(__FILE__) + '/../script/ical_hump.rb')

    notprinted = TRUE

    def self.process_calendar(user,calendar_object)
        calendar_read = TRUE
        three_months_ago = 12.months.ago.to_datetime
        cutoff_date = DateTime.new(2009,5,1) #when we make this live we will set this to 5/1/2009 so that we'll start from then
        process_time = DateTime.now
        
        #remove all entries using different ics files for this user from the processed_results table
        make_archived(calendar_object.id, 'calendar_id')

        ics_file = calendar_object.ics_file
	      puts ics_file
        http_user = calendar_object.http_user
        http_password = calendar_object.http_password
        # ===> if calendar opens
        # initialize your calendar
        
        begin
            puts "Checking location url: #{ics_file}"
            uri_parse = URI.parse(ics_file)
            puts "URI Parsed Successfully: #{uri_parse}"
                
            cal_file = open(uri_parse, :http_basic_authentication=>[http_user, http_password], :allow_unsafe_redirects => true).read
            puts "Calendar read"
            cals = Icalendar.parse(cal_file)
            puts "Calendar parsed"
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

    def self.process_user (user)
        if user.user_calendars.any?    
            # ===> for each ics_file   
            user.user_calendars.each do |calendar_object|
                process_calendar(user,calendar_object)
            end
            return TRUE
            # <=== for each calendar_object     
        end
        return FALSE
    end
end
