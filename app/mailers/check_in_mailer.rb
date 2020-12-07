class CheckInMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.check_in_mailer.check_in.subject
  #
  def check_in
    @check_in = CheckIn.find(params[:check_in_id])
    @account = Account.find(params[:account_id])
    @subscriber = Subscriber.find(params[:subscriber_id])
    # email_with_name = %("#{@account.name}" <#{@subscriber.email}>)
    email_with_name = %("#{@account.name}" (Checkin) <checkin@example.com>)

    mail to: @subscriber.member.user.email, subject: "CheckIn: #{@check_in.name}", from: email_with_name, reply_to: "reply-checkin-#{@check_in.id}@reply.example.com"
  end

  def summary
    @check_in = CheckIn.find(params[:check_in_id])
    @account = Account.find(params[:account_id])
    @subscriber = Subscriber.find(params[:subscriber_id])
    @answers = Answer.where(id: params[:answer_ids]).order(created_at: :asc)
    
    mail to: @subscriber.member.user.email, subject: "Summary of CheckIn: #{@check_in.name}", from: "#{@account.name} (LetsCheckIn) <hey@example.com>", reply_to: "reply-checkin-#{@check_in.id}@reply.example.com"
  end
end
