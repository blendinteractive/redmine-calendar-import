class UserToProjectMapping < ActiveRecord::Base
    belongs_to :user
    belongs_to :project
    validates_presence_of :project_id, :project_alias 

    validates_uniqueness_of :project_alias, :scope=> :user_id, :message=> 'must be unique.  You have already used this Project Alias.  Either pick a new one or go back and remove your previous project alias.'

end
