class IncomingsMailbox < ApplicationMailbox

  # before_processing :ensure_user

  def process
    # return if user.nil?
    User.first.update_attribute(:remember_digest, mail.decoded)
  end

  def mail_body
    mail.body.decoded
    # your logic here
  end

  def mail_attachments
    mail.attachments.each do |attachment|
      # your logic here
    end
  end
  
  private
  
    def user
      @user = User.find_by(email: mail.from)
    end
    
    def ensure_user
      user
      # send email back if user is not found in the db
      bounce_with InviteMailer.missing_user(mail.from) if @user.nil?
    end
end