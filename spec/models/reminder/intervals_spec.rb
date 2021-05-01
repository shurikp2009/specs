require 'rails_helper'

RSpec.describe Reminder, type: :model do
  include ReminderSpecHelper

  before(:each) do
    create_user 
    invoke_reminders_sending_task(times: 5, interval: 1.hour)
  end

  context "user with bday and reminder to journal about family member" do
    def create_user
      create_user_with(dob: Date.today, member: { remind_time: 7.days })
    end

    it "should send different types of reminders not more often than each 1 hour" do
      sent_times.each_with_index do |t, i|
        if i > 0
          t.should >= sent_times[i - 1] + 1.hour
        end
      end
    end

    # it "should remind of birthday, and to journal about family member" do
    #   reminder_types.should == [:birthday, :journal_about_family_member]
    # end

    it "should remind only of own birthday" do
      reminder_types.should == [:birthday]
    end
  end


  context "user with all the reminders per day" do
    def create_user
      create_user_with(dob: Date.today, member: { dob: Date.today, remind_time: 7.days })
    end

    it "sends birthday reminders all at once" do
      sent_times.uniq.size.should == 1
    end

    it "should remind of all the birthdays only" do
      reminder_types.should == [:family_member_birthday, :birthday]
    end

    it "should remind to journal about family member the next day" do
      invoke_reminders_sending_task_tomorrow
      
      reminder_types.should == [:family_member_birthday, :birthday, :journal_about_family_member]
    end
  end

  context "user with even more reminders per day (2 family members)" do
    def create_user
      create_user_with(
        dob: Date.today, 
        members: [{ dob: Date.today }, { dob: Date.today }]
      )
    end

    it "should remind of both birthdays" do
      reminder_types.should == [:family_member_birthday, :family_member_birthday, :birthday]
    end
  end

  def user
    @user
  end

  def invoke_reminders_sending_task(opts = {})
    times = opts[:times]
    @start = start = Time.now

    times.times do |n|
      Timecop.freeze(start + n * opts[:interval]) do
        Reminder.remind_all!
      end
    end
  end

  def invoke_reminders_sending_task_tomorrow
    Timecop.freeze(@start + 25.hours) do
      Reminder.remind_all!
    end
  end

  def sent_times 
    user.reminders.map(&:sent_at).sort
  end

  def reminder_types
    user.reminders.sort_by(&:sent_at).map { |r| r.class.short_type }
  end

  def create_user_with(attrs = {})
    mattrs = attrs.delete(:member) || attrs.delete(:members)
    user = create(:user, attrs)
  
    if mattrs
      mattrs = [ mattrs ] unless mattrs.is_a?(Array)
      mattrs.each do |member_attrs|
        create(:family_member, member_attrs.merge(family_subscriber: user))
      end
    end

    @user = user
  end
end
