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

class UserCalendar < ActiveRecord::Base
    belongs_to :user
    validates_presence_of :user_id
    validates_presence_of :name, :message => ': Calendar name cannot be blank'
    validates_presence_of :ics_file, :message => ': An ics file must be given'
    validates_uniqueness_of :ics_file, :message=>': This ics file has already been used. (by you or someone else)'

    
    has_many :script_created_issues, :foreign_key => 'user_calendar_id', :dependent => :delete_all
   
   #this needs to be set up later
   # has_many :processed_results, :foreign_key => 'user_calendar_id', :dependent => :delete_all
   
   User.class_eval do
     has_many :user_calendars
   end
end
