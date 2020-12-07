class CheckInSchedulerJob < ApplicationJob
  queue_as :default

  def perform(*args)
	  # get for the next hour
	  time = Time.now
	 	start_time = time.beginning_of_hour
	 	end_time = time.end_of_hour

	 	# CheckIn.active.each do |check_in|
	 	# 	if check_in.schedule.occurs_between?(start_time, end_time)
	 	# 		CheckInJob.perform_later(check_in.id)
	 	# 	end
	 	# end


	 	Subscriber.includes(:check_in).where(check_ins: {status: 0}).each do |subscriber|
	 			check_in = subscriber.check_in

	 			send_time = check_in.schedule.next_occurrence(time) # 08:00 utc
	 			last_sent = check_in.schedule.previous_occurrence(time)

	 		  utc_offset = Time.now.in_time_zone(subscriber.user.timezone).utc_offset / 3600 

        local_send_time = send_time - utc_offset.hour #07:00 utc = 08:00 berlin

        if local_send_time.between?(start_time, end_time)

        	#send summary
					if !check_in.last_sent.nil?
				    answer_ids = check_in.answers.where(created_at: last_sent..time).ids
      			unless answer_ids.blank?
          		CheckInMailer.with(check_in_id: check_in.id, account_id: check_in.account_id, subscriber_id: subscriber.id, answer_ids: answer_ids).summary.deliver_later(wait_until: local_send_time - 1.hour)
          	end
				  end

				  #send check-in
 					CheckInMailer.with(check_in_id: check_in.id, account_id: check_in.account_id, subscriber_id: subscriber.id).check_in.deliver_later(wait_until: local_send_time)
      		
      		check_in.update(last_sent: Time.now)
				end

	 	end
  end
end