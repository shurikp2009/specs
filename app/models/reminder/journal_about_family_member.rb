class Reminder::JournalAboutFamilyMember < Reminder::FamilyMember
  self.member_reminder_interval = 1.day

  class << self
    def user_scope
      test_mode? ? __user_scope__.where(users: {id: 7721 }) : __user_scope__
    end

    def __user_scope__
      User.
        joins('inner join users family_subscriber on family_subscriber.id = users.family_subscribe_id').
        joins("left outer join entries on entries.user_id = family_subscriber.id and entries.created_at >= DATE_SUB(CONVERT_TZ(NOW(), '#{Time.now.formatted_offset}', '+00:00'), INTERVAL `users`.`remind_time` DAY)").
        where('users.remind_time is not null and users.remind_time > 0').
        where(entries: {id: nil})
    end
  end

  def title
    "Reminder to Journal about #{family_member.first_name}"
  end

  def message
    "This is your friendly reminder to journal about #{family_member.first_name}"
  end

  def reminder_interval
    family_member.remind_time.days
  end
end