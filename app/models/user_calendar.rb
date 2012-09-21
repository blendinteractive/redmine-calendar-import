class UserCalendar < ActiveRecord::Base
    belongs_to :user
    validates_uniqueness_of :ics_file, :message=>'This ics file has already been used. (by you or someone else)'

    
    has_many :script_created_issues, :foreign_key => 'user_calendar_id', :dependent => :delete_all
   
   #this needs to be set up later
   # has_many :processed_results, :foreign_key => 'user_calendar_id', :dependent => :delete_all
   
   User.class_eval do
     has_many :user_calendars
   end
end
