class Reminder::Inactivity < Reminder
  self.reminder_interval = APP_CONFIG['inactivity_notification_interval'].days
  self.global_reminder_interval = 24.hours

  class << self
    def __user_scope__
      User.
      joins("LEFT OUTER JOIN entries ON entries.user_id = users.id and entries.created_at >= '#{(Time.now - reminder_interval).utc.to_s(:db)}'").
      where(entries: {id: nil})
    end
  end

  def title
    "Your Journal Misses You"
  end

  def message
    "Good time to journal? If so, take a few minutes to recap some of your favorite memories!"
  end
end