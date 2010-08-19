class Investor < ActiveRecord::Base

  has_many :investments
  attr_accessible :investor_name,:first_name, :last_name, :email, :password, :password_confirmation

  attr_accessor :password
  attr_accessor :remember_me
  before_save :prepare_password

  validates_presence_of :investor_name,:first_name, :last_name
  validates_uniqueness_of :investor_name, :email, :allow_blank => true
  validates_format_of :investor_name, :with => /^[-\w\._@]+$/i, :allow_blank => true, :message => "should only contain letters, numbers, or .-_@"
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
  validates_presence_of :password, :on => :create
  validates_confirmation_of :password
  validates_length_of :password, :minimum => 4, :allow_blank => true
  validates_uniqueness_of :authorization_token, :if => Proc.new { |investor| not investor.authorization_token.nil?}

  # login can be either investor_name or email address
  def self.authenticate(login, pass)
    investor = find_by_investor_name(login) || find_by_email(login)
    return investor if investor && investor.matching_password?(pass)
  end

  def matching_password?(pass)
    self.password_hash == encrypt_password(pass)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

#  def notifications
#    UserCommentNotification.find(:all, :conditions => ["user_id = ? AND mark_as_read = ?", self.id, false], :order => "created_at desc")
#  end

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
