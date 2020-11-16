require 'rails_helper'

RSpec.describe Reminder::JournalAboutFamilyMember, type: :model do
  include ReminderSpecHelper

  it "should remind user to journal about family member with set reminder and no entries" do
    should_remind user_with_family_member(
      to_remind_about: 1.day
    )
  end

  it "should not remind user to journal about family member with unset reminder and no entries" do
    should_not_remind user_with_family_member
  end

  it "should remind user to journal about family member with set reminder, when last posted about him too long ago" do
    should_remind user_with_family_member(
      to_remind_about: 7.days,
      last_entry_at: 7.days.ago - 1.minute
    )
  end

  it "should not remind user to journal about family member with set reminder, when last posted about him no earlier, than the [setting] days ago" do
    should_not_remind user_with_family_member(
      to_remind_about: 7.days,
      last_entry_at: 7.days.ago + 1.hour
    )
  end

  def user_with_family_member(options = {})
    remind_days = seconds_to_days options[:to_remind_about]
    
    opts = remind_days ? { remind_time: remind_days } : {}
    family_member = create(:family_member, opts)

    user = family_member.family_subscriber

    if entry_at = options[:last_entry_at]
      create(:entry, members: [ family_member ], user: user, entry_date: entry_at, created_at: entry_at)
    end

    user
  end

  def seconds_to_days(arg)
    arg / (60 * 60 * 24) if arg
  end
end
