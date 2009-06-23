require File.dirname(__FILE__) + '/../spec_helper'

describe PhotoReceiver do
  fixtures :parties

  before do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
  end

  it "should receive email to invalid address and send error" do
    # Notifier.should_receive(:deliver_invalid_party).with("test@z.vodafone.ne.jp", "badparty@smillie.jp")
    @emails = ActionMailer::Base.deliveries
    PhotoReceiver.receive <<-EOS
Return-Path: <test@z.vodafone.ne.jp>
Delivered-To: badparty@smillie.jp
Subject: test

EOS
    @emails.size.should == 1
    reply = @emails[0]
    reply.to.to_s.should == "test@z.vodafone.ne.jp"
    reply.body.should =~ /存在しません/
  end

  it "should receive email to valid address" do
    photo_count = Photo.count
    email = open("#{File.dirname(__FILE__)}/../fixtures/emails/email_with_png_file.txt"){|f|f.read}
    email.sub!(/Delivered-To: .*/, "Delivered-To: marriage@smillie.jp")
    PhotoReceiver.receive email
    assert_equal photo_count + 1, Photo.count
  end

  it "should receive email with image in body to valid address" do
    photo_count = Photo.count
    email = open("#{File.dirname(__FILE__)}/../fixtures/emails/email_with_image_body.txt"){|f|f.read}
    email.sub!(/Delivered-To: .*/, "Delivered-To: marriage@smillie.jp")
    PhotoReceiver.receive email
    assert_equal photo_count + 1, Photo.count
  end
end
