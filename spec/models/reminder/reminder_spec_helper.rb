module ReminderSpecHelper
  def reminded_users
    change_in -> { described_class.all.to_a } do
      described_class.remind!  
    end.map(&:user)
  end

  def change_in(proc, &block)
    before = proc.call
    yield
    after = proc.call

    after - before
  end
  
  def should_remind(user, time = nil)
    check = proc { reminded_users.should include(user) }
    time ? Timecop.freeze(time, &check) : check.call
  end

  def should_not_remind(user, time = nil)
    check = proc { reminded_users.should_not include(user) }
    time ? Timecop.freeze(time, &check) : check.call
  end
end