
ActionController::Routing::Routes.draw do |map|
  map.connect 'calendar_import', :controller => 'calendar_imports'
  map.connect 'user_calendar', :controller => 'user_calendars'
  map.resource :user_calendars
  map.resource :user_to_project_mappings
  map.resource :event_to_issue_errors
  map.resource :skipped_entry
end
