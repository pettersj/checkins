class CheckInsMailbox < ApplicationMailbox

	MATCHER = /reply-checkin-(.+)@reply.example.co/i

  # mail => Mail object
  # inbound_email => ActionMailbox::InboundEmail record

  # before_processing :ensure_member

  def process
    return if member.nil?

  	Answer.create!(user: user, check_in: check_in, account: check_in.account, body: body, member: member)
  end

  def attachments
    @_attachments = mail.attachments.map do |attachment|
      blob = ActiveStorage::Blob.create_after_upload!(
        io: StringIO.new(attachment.body.to_s),
        filename: attachment.filename,
        content_type: attachment.content_type,
      )
      { original: attachment, blob: blob }
    end
  end

  def body
    if mail.multipart? && mail.html_part
      document = Nokogiri::HTML(mail.html_part.body.decoded)

      attachments.map do |attachment_hash|
        attachment = attachment_hash[:original]
        blob = attachment_hash[:blob]

        if attachment.content_id.present?
          # Remove the beginning and end < >
          content_id = attachment.content_id[1...-1]
          element = document.at_css "img[src='cid:#{content_id}']"

          element.replace "<action-text-attachment sgid=\"#{blob.attachable_sgid}\" content-type=\"#{attachment.content_type}\" filename=\"#{attachment.filename}\"></action-text-attachment>"
        end
      end
      document.at_css("blockquote").remove if !document.at_css("blockquote").nil? #removes original email
      document.at_css("body").inner_html.encode('utf-8')
    else
      mail.parse
    end

  end

  def user
    email = mail.from.first
  	@user ||= User.find_by(email: email)
    return @user
  end

  def member
    if !user.nil?
      @member = check_in.account.members.find_by(user_id: @user.id)
    end
  end

  def check_in
  	@check_in ||= CheckIn.find(check_in_id)
  end

  def check_in_id
  	recipient = mail.recipients.find{|r| MATCHER.match?(r)}
  	recipient[MATCHER, 1]
  end


  def ensure_user
  	if user.nil?
  		# bounce_with CheckInMailer.missing(inbound_email)
  	end
  end
end
