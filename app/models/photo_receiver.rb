class PhotoReceiver < ActionMailer::Base
  def receive(email)
    if email.delivered_to =~ /^(.*?)@/
      key = $1.downcase
      party = Party.find_by_key(key)
      if party
        if email.has_attachments?
          email.attachments.each do |att|
            Photo.create!(:party => party, :posted_by => email.return_path, :file => att)
          end
        elsif email.content_type =~ /^image\//
          Photo.create!(:party => party, :posted_by => email.return_path, :file => StringIO.new(email.body))
        end
      else
        Notifier.deliver_invalid_party(email.return_path, key)
      end
    else
      Notifier.deliver_invalid_party(email.return_path, email.delivered_to)
    end
  end
end
