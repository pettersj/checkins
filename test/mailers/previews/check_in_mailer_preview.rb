# Preview all emails at http://localhost:3000/rails/mailers/check_in_mailer
class CheckInMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/check_in_mailer/check_in
  def check_in
    CheckInMailer.check_in
  end

  def summary
    CheckInMailer.summary
  end

end
