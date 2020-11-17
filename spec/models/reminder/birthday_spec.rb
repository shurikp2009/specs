require 'rails_helper'

RSpec.describe Reminder::Birthday, type: :model do
  include ReminderSpecHelper

  it "should remind user, whose birthday is today" do
    should_remind birthday_user
  end

  it "should not remind user, whose birthday is not today" do
    should_not_remind create(:user, dob: Date.tomorrow)
  end

  it "should not remind more than one time per (birth)day" do
    should_remind birthday_user

    should_not_remind birthday_user, 1.minute.from_now
    should_not_remind birthday_user, 1.hour.from_now
    should_not_remind birthday_user, 12.hours.from_now
  end

  def birthday_user
    @bd_user ||= create(:user, dob: Date.today)
  end
end
