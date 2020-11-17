class Reminder < ApplicationRecord
  belongs_to :user
  serialize :data, Hash

  scope :recent, -> { order('created_at desc') }
  after_create :send_push
  before_create :assign_counter

  class_attribute :reminder_interval
  class_attribute :global_reminder_interval

  self.global_reminder_interval = 1.hour

  ALPHA_USERS = [
    'crossfire110@aol.com', 
    'ken@legacyoflove.app', 
    'nina@calibrated.io',
    'shurikp2009@yandex.com',
    'ken@kwnetlease.com',
    'kpb99@aol.com'
  ]

  def self.test_mode?
    Rails.env.development?
  end
  
  def self.test_user
    User.find_by_email 'shurikp2009@yandex.com'
  end

  def self.alpha_mode?
    Rails.env.staging?
  end

  def self.alpha_user_ids
    User.where(email: ALPHA_USERS).pluck(:id)
  end

  def self.alpha_users
    User.where(email: ALPHA_USERS)
  end

  def self.all_alpha_users
    @aau ||= alpha_users + User.where(id: alpha_user_family_ids).all
  end

  def self.alpha_user_family_ids
    User.where(family_subscribe_id: alpha_user_ids).pluck(:id)
  end

  delegate :test_mode?, :test_user, to: 'self.class'
  delegate :alpha_mode?, :alpha_users, to: 'self.class'

  def prev_scope
    self.class.where(user_id: user.id).recent
  end

  def prev
    prev_scope.first
  end

  def any_prev
    Reminder.where(user_id: user.id).recent.first
  end

  def received_this_reminder?(period = nil)
    prev && (!period || prev.sent_at >= period.ago)
  end

  def _alpha_dont_send?
    alpha_mode? && !self.class.all_alpha_users.include?(user)
  end

  def remind_now?
    return false if !user.fcm_token && send_real_push?
    return false if _alpha_dont_send?
    # test_mode? || !received_this_reminder? && !enough_time_passed_globally?
    test_mode? || enough_time_passed_globally? && enough_time_passed?
  end

  def send_real_push?
    !Rails.env.test?
  end

  def send_push
    return if test_mode? && user != test_user
    return false if _alpha_dont_send?

    time     = Time.now
    title    = self.title
    message  = self.message

    begin
      response = if send_real_push?
        real_title = title
        real_title = "[TEST] " + real_title if Rails.env.staging? || Rails.env.development?
        FcmService.push( [ user.fcm_token ], real_title, message, user.id, 'User' )
      else
        { response: 'success' }
      end
    rescue => e
      response = { exception: e.to_s }
    end  

    success = response[:response] == 'success'
      
    self.data = {
      title:        title,
      message:      message,
      fcm_response: response
    }
    
    self.sent_at = time if success
    self.status = success ? 'sent' : 'failed'

    self.save
  end

  def assign_counter
    self.counter = prev_scope.count + 1
  end

  def enough_time_passed?
    !reminder_interval || !prev || prev.sent_at <= Time.now - reminder_interval
  end

  def enough_time_passed_globally?
    !global_reminder_interval || !any_prev || any_prev.sent_at && any_prev.sent_at <= Time.now - global_reminder_interval
  end

  class << self
    def user_scope
      if @user_scope
        User.send(@user_scope)
      else
        test_mode? ? [ test_user ] : __user_scope__
      end
    end

    def user_scope=(scope)
      @user_scope = scope
    end

    def push_scope
      user_scope.is_a?(Array) ? user_scope.select(&:fcm_token) : user_scope.where.not(fcm_token: nil)
    end

    def each_in_push_scope(&block)
      ps = push_scope
      method = ps.is_a?(Array) ? :each : :find_each
      ps.send(method, &block)
    end

    def remind!
      each_in_push_scope do |user| 
        reminder = reminder_for_record(user)
        reminder.save! if reminder && reminder.remind_now?
      end
    end

    def pending_reminders
      [].tap do |result|
        each_in_push_scope do |user| 
          reminder = reminder_for_record(user)
          result << reminder if reminder && reminder.remind_now?
        end
      end
    end

    def reminder_for_record(user)
      reminder = self.new(user: user)
    end

    DEFAULT_REMINDERS = [
      :family_member_birthday, :birthday,
      :journal_about_family_member,
      :inactivity
    ]

    def remind_all!(names = DEFAULT_REMINDERS)
      klasses = names.map { |name| const_get name.to_s.camelize }

      klasses.each(&:remind!) 
    end

    def all_pending_reminders(names = DEFAULT_REMINDERS)
    end

    def short_type
      self.name.demodulize.underscore.to_sym
    end
  end
end
