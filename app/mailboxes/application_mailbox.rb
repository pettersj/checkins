class ApplicationMailbox < ActionMailbox::Base
	routing /reply-checkin-(.+)@reply.example.com/i => :check_ins
end
