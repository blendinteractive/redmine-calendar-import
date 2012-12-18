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

require 'rubygems' # Unless you install from the tarball or zip.
basepath = File.dirname(__FILE__) + '/../../../../'
require basepath + 'config/boot'
require basepath + 'config/environment'
require 'date'
require 'active_support'

if (ARGV.length < 1)
    #delete from processed_results where date < 3 months ago
    three_months_ago = 12.months.ago.to_datetime
    make_archived(three_months_ago, 'date')

    user_ids = UserCalendar.find_by_sql(["SELECT DISTINCT(user_id) FROM user_calendars"]).collect(&:user_id)
    user_list = User.find_all_by_id(user_ids)

    # ===> each user with an ICS file to import
    user_list.each do |user|
        puts "Starting user: #{user.login}"
        ImportProcessor::process_user(user)
    end
else
    ARGV.each do|name|
        puts "Starting user with firstname: #{name}"
        user = User.find_by_firstname(name)
        ImportProcessor::process_user(user)
    end
end
# <=== each user with an ICS file to import
