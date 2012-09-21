module UserCalendarsPatch
  def self.included(base)
    base.class_eval do
      has_many :user_calendars
      has_many :user_to_project_mappings
      has_many :event_to_issue_errors
      has_many :skipped_entries
    end
  end
end