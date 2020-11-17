class Reminder::FamilyMember < Reminder
  belongs_to :family_member, class_name: 'User', foreign_key: :record_id
  class_attribute :member_reminder_interval

  class << self
    def reminder_for_record(user)
      if fs = user.family_subscriber
        self.new(
          user: fs,
          family_member: user
        )
      end
    end

    def push_scope
      user_scope
    end
  end

  def prev_scope
    self.class.where(user_id: user.id, record_id: family_member.id).recent
  end

  def prev_member_scope
    Reminder.where(user_id: user.id, record_id: family_member.id).recent
  end

  def prev_member
    prev_member_scope.first
  end

  def remind_now?
    super && (
      test_mode? || enough_time_passed_for_this_member?
    )
  end

  def enough_time_passed_for_this_member?
    !member_reminder_interval || !prev_member || prev_member.sent_at <= Time.now - member_reminder_interval
  end
end