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


RedmineApp::Application.routes.draw do
  match 'calendar_import/:name' => 'calendar_imports#user_index'
  match 'calendar_import/:name/pull' => 'calendar_imports#user_pull'
  match 'calendar_import' => 'calendar_imports#index'
  
  match 'user_calendars/show/:id' => 'user_calendars#show', :as => "show_user_calendar", :via => :get
  match 'skipped_entries/show/:id' => 'skipped_entries#show', :as => "show_skipped_entries", :via => :get  
  
  resources :user_calendars
  resources :user_to_project_mappings
  resources :event_to_issue_errors
  #resources :skipped_entries
end
