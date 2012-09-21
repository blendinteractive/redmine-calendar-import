class ProcessedResult < ActiveRecord::Base
    belongs_to :user
    belongs_to :user_calendar
end
