class Reminder::JournalAboutFamilyMember < Reminder::FamilyMember
  self.member_reminder_interval = 1.day

  class << self
    def user_scope
      test_mode? ? __user_scope__.where(users: {id: 7721 }) : __user_scope__
    end

    def __user_scope__
      base_scope = User.where('users.remind_time is not null and users.remind_time > 0 and family_subscribe_id is not null')

      were_posted_about = base_scope.joins(:assign_entries).where("entries.created_at >= DATE_SUB(CONVERT_TZ(NOW(), '#{Time.now.formatted_offset}', '+00:00'), INTERVAL `users`.`remind_time` DAY)")

      ids = were_posted_about.pluck(:id)
      ids.empty? ? base_scope : base_scope.where("id not in (?)", ids)
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