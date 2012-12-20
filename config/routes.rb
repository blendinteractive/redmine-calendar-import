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

ActionController::Routing::Routes.draw do |map|
  map.connect 'calendar_import/:name/', :controller => 'calendar_imports', :action => 'user_index'
  map.connect 'calendar_import/:name/pull', :controller => 'calendar_imports', :action => 'user_pull'
  map.connect 'calendar_import', :controller => 'calendar_imports'
  map.connect 'user_calendar', :controller => 'user_calendars'
  map.resource :user_calendars
  map.resources :user_to_project_mappings
  map.resources :event_to_issue_errors
  map.resource :skipped_entry
end
