class Reminder::Birthday < Reminder
  self.user_scope = :birthday_cst
  self.reminder_interval = 1.day
  self.global_reminder_interval = nil

  def title
    "It’s your birthday!"
  end

  def message
    "Happy birthday from the Legacy of Love family. Make a journal entry about some of your best lessons or memories from the year!"
  end
end