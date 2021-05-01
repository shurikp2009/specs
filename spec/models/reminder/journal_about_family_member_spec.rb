require 'rails_helper'

RSpec.describe Reminder::JournalAboutFamilyMember, type: :model do
  include ReminderSpecHelper

  it "should remind user to journal about family member with set reminder and no entries" do
    should_remind user_with_family_member(
      to_remind_about: 1.day
    )
  end

  it "should remind user to journal about family member no often than setting" do
    should_remind user_with_family_member(
      to_remind_about: 7.days
    )

    should_not_remind user, 7.days.from_now - 1.minute
  end

  it "should remind user to journal about family again after more time passes (according to setting)" do
    should_remind user_with_family_member(
      to_remind_about: 7.days
    )

    should_remind user, 7.days.from_now + 1.minute
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

  it "should remind user to journal about family member with set reminder, when last posted about him too long ago, even if then posted about some other family member" do
    user_with_family_member(
      to_remind_about: 7.days,
      last_entry_at: 7.days.ago - 1.minute
    )

    has_another_member( last_entry_at: 2.days.ago )
    
    should_remind @user
    should_remind_about family_member
    should_not_remind_about another_member
  end

  it "should not remind user to journal about family member with set reminder, when last posted about him no earlier, than the [setting] days ago" do
    should_not_remind user_with_family_member(
      to_remind_about: 7.days,
      last_entry_at: 7.days.ago + 1.hour
    )
  end

  it "should not remind user to journal about family member with set reminder, when last posted about him no earlier, than the [setting] days ago, and when he also posted earlier" do
    should_not_remind user_with_family_member(
      to_remind_about: 7.days,
      entries_at: [ 7.days.ago + 1.hour, 10.days.ago ]
    )
  end

  def handle_entries(member, options)
    if entry_at = options[:last_entry_at]
      create_entry_about(member, entry_at)
    end

    if times = options[:entries_at]
      times.each { |entry_at| create_entry_about(member, entry_at) }
    end
  end

  def user_with_family_member(options = {})
    @user          = create(:user)
    @family_member = family_member = create_family_member(options)
    handle_entries(family_member, options)

    @user
  end

  def has_another_member(options = {})
    @another_member = create_family_member(options)
    handle_entries(@another_member, options)
  end

  def create_entry_about(member, time)
    create(:entry, members: [ member ], user: user, entry_date: time, created_at: time)
  end

  def create_family_member(options = {})
    remind_days = seconds_to_days options[:to_remind_about]
    
    opts = { family_subscriber: @user }
    opts[:remind_time] = remind_days

    create(:family_member, opts)
  end

  attr_reader :family_member, :another_member, :user

  def seconds_to_days(arg)
    arg / (60 * 60 * 24) if arg
  end

  def reminder_about(member)
    @user.reminders.find do |reminder| 
      reminder.is_a?(described_class) && reminder.family_member == member
    end
  end

  def should_remind_about(member)
    expect(reminder_about(member)).to be
  end

  def should_not_remind_about(member)
    expect(reminder_about(member)).not_to be
  end
end
