require 'open-uri'


class Calendar
    #make all of the functions protected
    protected
    #this can be it's own module if need be
    include Icalendar # Probably do this in your class to limit namespace overlap
    cal_file=''
    # Open a file or pass a string to the parser
    
    def initialize(file_name)
    end 



    # Parser returns an array of calendars because a single file can have multiple calendars.
    #cals = Icalendar.parse(cal_file)
    #cal = cals.first
end