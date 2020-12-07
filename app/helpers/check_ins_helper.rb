module CheckInsHelper

	def checkin_display_name(check_in)
		if check_in.schedule_period == "daily"
			"Every #{check_in.weekday.to_sentence} at #{check_in.time.strftime("%H:%M")} "

		elsif check_in.schedule_period == "weekly"
			"#{check_in.weekday.to_sentence} every week at #{check_in.time.strftime("%H:%M")}"

		elsif check_in.schedule_period == "two_weeks"
			"#{check_in.weekday.to_sentence} every two weeks at #{check_in.time.strftime("%H:%M")}"

		elsif check_in.schedule_period == "monthly"
			"The first #{check_in.weekday} at #{check_in.time.strftime("%H:%M")} every month"
		end 
	end
end
