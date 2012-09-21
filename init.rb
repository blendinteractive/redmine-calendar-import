# Empty redmine plguin
require 'redmine'
# TODO: Change this to use the name of your plugin
RAILS_DEFAULT_LOGGER.info 'Starting Calendar Import plugin for RedMine'

# TODO: Change the name 
Redmine::Plugin.register :calendar_import do
  name 'Calendar Import'
  author 'Blend Interactive'
  description 'This to allow users to create time entries and issues directly from the calendar system they are using.'
  version '0.1.0'

  menu(:top_menu, :calendar_imports, {:controller => "calendar_imports", :action => 'index'}, :caption => 'Calendar Import', :if => Proc.new{ User.current.logged? })
end

require 'dispatcher'
Dispatcher.to_prepare :calendar_import_plugin do
  require_dependency 'principal'
  require_dependency 'user'
  require_dependency 'project'
  User.send(:include,UserCalendarsPatch)
  Project.send(:include,ProjectPatch)
end

