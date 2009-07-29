class User < ActiveRecord::Base
  #define_read_methods
  asymmetrically_encrypts :creditcard
  
  #def self.validates_password
  #  validates_presence_of :password
  #  validates_presence_of :password, :on => :create
  #  validates_length_of :password, :in => 4..40
  #end
end

#class ShaUser < User
#  validates_password
#  validates_confirmation_of :password
#  generates_crypted :password # sha is used by default
#end
#
#class DangerousUser < User # no password confirmation
## validates_password
#  generates_crypted :password
#end
#
#class SymmetricUser < User
#  validates_password
#  generates_crypted :password, :mode => :symmetric
#end