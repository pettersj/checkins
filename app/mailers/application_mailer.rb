class ApplicationMailer < ActionMailer::Base
  default from: %(Checkin <hey@example.co>)
  layout 'mailer'
end
