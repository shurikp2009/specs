require 'rails_helper'

RSpec.describe Reminder::Inactivity, type: :model do
  include ReminderSpecHelper

  it "should send reminder each 15 days, when more than 15 days passed since last entry" do
    should_remind_each_15_days user_with_entry(
      made_at: 15.days.ago - 1.minute
    )
  end

  it "should send reminder each 15 days to user with no entries" do
    should_remind_each_15_days create(:user)
  end

  it "should not send reminder after less than 15 days of no entries" do
    should_not_remind user_with_entry(
      made_at: 15.days.ago + 1.minute
    )
  end

  it "should send reminder after 15 days of no entries, and then after 15 more days if still no entries" do
    should_remind user_with_entry(
      made_at: 15.days.ago - 1.minute
    )

    should_remind user, 15.days.from_now + 1.minute
  end

  it "should not send reminders more often than each 15 days" do
    should_remind user_with_entry(
      made_at: 15.days.ago - 1.minute
    )

    should_not_remind user, 15.days.from_now - 1.hour
  end

  def should_remind_each_15_days(user)
    should_remind user
    should_remind user, 15.days.from_now + 1.minute
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
