module ProjectPatch
  def self.included(base)
    base.class_eval do
      has_many :user_to_project_mappings
    end
  end
end