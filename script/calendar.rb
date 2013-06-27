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

require 'open-uri'


class Calendar
    #make all of the functions protected
    protected
    #this can be it's own module if need be
    #include Icalendar # Probably do this in your class to limit namespace overlap
    cal_file=''
    # Open a file or pass a string to the parser
    
    def initialize(file_name)
    end 



    # Parser returns an array of calendars because a single file can have multiple calendars.
    #cals = Icalendar.parse(cal_file)
    #cal = cals.first
end