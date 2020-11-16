require 'rails_helper'

RSpec.describe Reminder::Inactivity, type: :model do
  include ReminderSpecHelper

  it "should send reminder after 15 days of no entries" do
    should_remind user_with_entry(
      made_at: 15.days.ago - 1.minute
    )
  end

  it "should not send reminder after less than 15 days of no entries" do
    should_not_remind user_with_entry(
      made_at: 15.days.ago + 1.minute
    )
  end

  it "should send reminder after 15 days of no entries, and the next day too" do
    should_remind user_with_entry(
      made_at: 15.days.ago - 1.minute
    )

    should_remind user, tomorrow
  end

  it "should not send reminders more often than each 24 hours" do
    should_remind user_with_entry(
      made_at: 15.days.ago - 1.minute
    )

    should_not_remind user, 23.hours.from_now
  end

  def user_with_entry(*attrs)
    @user = create(:user_with_entry, *attrs)
  end

  def user
    @user
  end

  def tomorrow
    Time.now + 24.hours
  end
end
