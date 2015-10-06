class Panel < ActiveRecord::Base

belongs_to :project
acts_as_list :scope => :project

scope :sorted, lambda { order("panels.position ASC")}

end
