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
    Time.stub(:now).and_return(time) if time
    reminded_users.should include(user)
  end

  def should_not_remind(user, time = nil)
    Time.stub(:now).and_return(time) if time
    reminded_users.should_not include(user)
  end
end