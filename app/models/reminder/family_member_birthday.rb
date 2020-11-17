class Reminder::FamilyMemberBirthday < Reminder::FamilyMember
  self.user_scope = :birthday_cst
  self.reminder_interval = 1.day
  self.global_reminder_interval = nil

  def title
    "It's #{family_member.first_name}'s Birthday today!"
  end

  def message
    "Celebrate, express gratitude, and memorialize the day in your journal"
  end
end