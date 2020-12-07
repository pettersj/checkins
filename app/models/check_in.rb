class CheckIn < ApplicationRecord
	enum schedule_period: {daily: 0, weekly: 1, two_weeks: 2, monthly: 3}
	enum status: {active: 0, inactive: 1}
  belongs_to :account
  belongs_to :user
  has_many :answers, dependent: :destroy
  has_many :subscribers, dependent: :destroy
  has_many :members, through: :subscribers

  after_create :create_subscribers

  def schedule
  	start_time = (self.created_at.beginning_of_day + self.time.seconds_since_midnight).to_time
  	set_schedule = IceCube::Schedule.new(start = start_time)

  	if self.daily?
  		days = self.weekday.collect{|c| c.to_sym}
  		set_schedule.add_recurrence_rule IceCube::Rule.weekly.day(days)
  	end

  	if self.weekly?
  		set_schedule.add_recurrence_rule IceCube::Rule.weekly(1, :monday).day(self.weekday.first.to_sym)
  	end

  	if self.two_weeks?
  		set_schedule.add_recurrence_rule IceCube::Rule.weekly(2, :monday).day(self.weekday.first.to_sym)
  	end

  	if self.monthly?
  		set_schedule.add_recurrence_rule IceCube::Rule.monthly(1, :monday).day_of_month(self.weekday_int)
  	end

  	return set_schedule
  end


  def create_subscribers
    account_id = self.account_id
    check_in_id = self.id
    members = self.account.members.collect{|c| {member_id: c.id, account_id: account_id, check_in_id: check_in_id}}
    subscribers = Subscriber.create(members)
  end

  def weekday_int
  	case self.weekday
  	when 'monday'
  		1
  	when 'tuesday'
  		2
  	when 'wednesday'
  		3
  	when 'thursday'
  		4
  	when 'friday'
  		5
  	when 'saturday'
  		6
  	when 'sunday'
  		0
  	end
  		
  end

end
