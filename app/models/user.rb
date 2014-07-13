class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable, :timeoutable and 
  # :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :login, :email, :password, :password_confirmation, :remember_me
  
  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login
  
  has_many :lexicons
  has_many :conlangs
  has_many :lexemes, :through => :lexicons
  
  before_save { |user| user.email = email.downcase }
  
  # Basic sanity checking rather than ensuring it complies to the spec.
  email_regex = /\b.+@.+\..+\b/i
  
  validates :name,
            :presence     => true,
            :length       => { :within => 4..20 },
            :uniqueness   => { :case_sensitive => false }
  validates :email,
            :presence     => true,
            :format       => { :with => email_regex },
            :uniqueness   => { :case_sensitive => false }
  validates :password,
            :presence     => true,
            :confirmation => true,
            :length       => { :minimum => 8 }
  validates :password_confirmation,
            :presence     => true

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(name) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end
end
