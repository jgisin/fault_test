class Project < ActiveRecord::Base

belongs_to :user	
has_many :panels, :dependent => :destroy
acts_as_list :scope => :user

scope :sorted, lambda { order("projects.position ASC")}

end
