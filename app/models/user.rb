class User < ActiveRecord::Base
  # new columns need to be added here to be writable through mass assignment
  attr_accessible :username, :email, :password, :password_confirmation, :first_name, :last_name, :role, :team_id, :manager, :available, :reset_password_at_next_login, :login_suspended
  
  attr_accessor :password
  attr_accessor :remember_me
  before_save :prepare_password
  has_many :logs
  has_many :loans_as_underwriter, :as => :underwriter, :class_name => 'Loan', :include => :customer
  has_many :loans_as_collections_agent, :as => :collections_agent, :class_name => 'Loan', :include => [:customer, :loan_transactions]
  has_many :loans_as_garnishments_agent, :as => :garnishments_agent, :class_name => 'Loan', :include => :customer
  
  has_and_belongs_to_many :locations
  belongs_to :team
  validates_presence_of :username
  validates_uniqueness_of :username, :email, :allow_blank => true
  validates_format_of :username, :with => /^[-\w\._@]+$/i, :allow_blank => true, :message => "should only contain letters, numbers, or .-_@"
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
  validates_presence_of :password, :on => :create
  validates_confirmation_of :password
  validates_length_of :password, :minimum => 4, :allow_blank => true
  validates_uniqueness_of :authorization_token, :if => Proc.new { |user| not user.authorization_token.nil?}

  validates_presence_of :role, :first_name, :last_name
  validates_presence_of :team_id, :if => Proc.new { |user| ['underwriter','collections','garnishments'].include? user.role}
  
  named_scope :underwriters,        :conditions => "role = 'underwriter'"
  named_scope :collections_agents,  :conditions => "role = 'collections'"
  named_scope :garnishment_agents,  :conditions => "role = 'garnishments'"
  named_scope :investors, :conditions => "role = 'investor'"

  # Roles
  ROBOT         = 'robot'
  ADMINISTRATOR = 'administrator'
  UNDERWRITER   = 'underwriter'
  COLLECTIONS   = 'collections'
  GARNISHMENTS  = 'garnishments'
  INVESTOR      = 'investor'

  ROLES = [ROBOT,ADMINISTRATOR, UNDERWRITER, COLLECTIONS,GARNISHMENTS, INVESTOR]
  
  # login can be either username or email address
  def self.authenticate(login, pass)
    user = find_by_username(login) || find_by_email(login)
    return user if user && user.matching_password?(pass)
  end
  
  def is_underwriter?
    self.role == UNDERWRITER
  end

  def is_collections_agent?
    self.role == COLLECTIONS
  end

  def is_garnishments_agent?
    self.role == GARNISHMENTS
  end
  
  def matching_password?(pass)
    self.password_hash == encrypt_password(pass)
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def self.next_underwriter
    next_underwriter = User.underwriters.first
    User.underwriters.all.each do |u|
      next unless u.available
      if u.loans_as_underwriter.count < next_underwriter.loans_as_underwriter.count
        next_underwriter = u
      end
    end
    return next_underwriter
  end

  def self.next_collections_agent
    next_collections_agent = User.collections_agents.first
    User.collections_agents.all.each do |u|
      next unless u.available
      if u.loans_as_collections_agent.count < next_collections_agent.loans_as_collections_agent.count
        next_collections_agent = u
      end
    end
    return next_collections_agent
  end

  def self.next_garnishment_agent
    next_garnishment_agent = User.garnishment_agents.first
    User.garnishment_agents.all.each do |u|
      next unless u.available
      if u.loans_as_garnishments_agent.count < next_garnishment_agent.loans_as_garnishments_agent.count
        next_garnishment_agent = u
      end
    end
    return next_garnishment_agent
  end
  
  def notifications
    UserCommentNotification.find(:all, :conditions => ["user_id = ? AND mark_as_read = ?", self.id, false], :order => "created_at desc")
  end

  def reminders
    loan_ids = []
    loans = []
    case role
    when 'underwriter'
      loans = loans_as_underwriter
    when 'collections'
      loans = loans_as_collections_agent
    when 'garnishments'
      loans = loans_as_garnishments_agent
    end
    loans.each do |loan|
      loan_ids << loan.id
    end
    Reminder.find(:all, :conditions => ["loan_id in (?)",loan_ids], :include => :loan)
  end

  def reminders_today
    today = []
    reminders.each do |reminder|
      today << reminder if reminder.remind_on == Date.today
    end
    today
  end

  def reminders_since(date)
    since = []
    reminders.each do |reminder|
      since << reminder if reminder.remind_on > date
    end
    since
  end
  
  private
  
  def prepare_password
    unless password.blank?
      self.password_salt = Digest::SHA1.hexdigest([Time.now, rand].join)
      self.password_hash = encrypt_password(password)
    end
  end
  
  def encrypt_password(pass)
    Digest::SHA1.hexdigest([pass, password_salt].join)
  end
end
