class ScriptCreatedIssue < ActiveRecord::Base
    belongs_to :user
    belongs_to :user_calendar
    belongs_to :issue
    belongs_to :project

end
