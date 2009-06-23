class Notifier < ActionMailer::Base
  def invalid_party(sender, name)
    from ADMIN_EMAIL
    recipients sender
    subject "存在しないイベント名です"
    body "「#{name}」 というイベントは存在しません。宛先が正しいかどうか確認してください。"
  end

  def inquiry_for_user(inquiry)
    from ADMIN_EMAIL
    recipients inquiry.email
    subject "【Smillie!】お問い合わせを受け付けました"
    body :inquiry => inquiry
  end

  def inquiry_for_admin(inquiry)
    from ADMIN_EMAIL
    recipients ADMIN_EMAIL
    subject "【重要】Smillie! のお問い合わせ"
    body :inquiry => inquiry
  end

  # 以下、日本語化のためのメソッド

  def subject(*params)
    if params.empty?
      super
    else
      super(NKF.nkf("-M", NKF.nkf("-Wj", params.first)))
    end
  end

  def create_mail_with_encode_body
    @body = NKF.nkf("-Wj", @body) if @parts.empty?
    create_mail_without_encode_body
  end

  alias_method_chain :create_mail, :encode_body

end
