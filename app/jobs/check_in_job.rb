class CheckInJob < ApplicationJob
  queue_as :default

  def perform(check_in_id)
    # Time.zone = "UTC"
    @check_in = CheckIn.find(check_in_id)
    subscribers = @check_in.subscribers
    time = Time.now.beginning_of_hour

    # send summary of last periods answers
    if !@check_in.last_sent.nil?
      answer_ids = @check_in.answers.where(created_at: @check_in.last_sent..Time.now).ids

      unless answer_ids.blank?
        subscribers.each do |subscriber|
          send_time = @check_in.schedule.next_occurrence(time) - 1.hour #send summary of previous period 1 hour before a new check in is sent
          utc_offset = Time.now.in_time_zone(subscriber.user.timezone).utc_offset / 3600

          if utc_offset < 0
            new_send_time = (send_time - utc_offset.hour) + 1.day
          else
            new_send_time = send_time - utc_offset.hour
          end

          CheckInMailer.with(check_in_id: @check_in.id, account_id: @check_in.account_id, subscriber_id: subscriber.id, answer_ids: answer_ids).summary.deliver_later(wait_until: new_send_time)
        end
      end
    end

    if @check_in.active?
	    subscribers.each do |subscriber|
        send_time = @check_in.schedule.next_occurrence(time)
        utc_offset = Time.now.in_time_zone(subscriber.user.timezone).utc_offset / 3600

        if utc_offset > 0
          new_send_time = (send_time - utc_offset.hour) + 1.day
        else
          new_send_time = send_time - utc_offset.hour
        end

	    	mailer = CheckInMailer.with(check_in_id: @check_in.id, account_id: @check_in.account_id, subscriber_id: subscriber.id).check_in.deliver_later(wait_until: new_send_time)
        
      end
      @check_in.update(last_sent: Time.now)
		end


  end
end