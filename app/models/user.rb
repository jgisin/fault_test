class User < ActiveRecord::Base

has_secure_password

validates_presence_of :user_name
validates_length_of :user_name, :maximum => 15
validates_uniqueness_of :user_name
validates_presence_of :email
validates_uniqueness_of :email
validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

has_many :projects, :dependent => :destroy

end
