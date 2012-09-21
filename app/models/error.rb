class Error < ActiveRecord::Base
    has_many :event_to_issue_errors, :foreign_key => 'error_id'
end