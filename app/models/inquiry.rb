class Inquiry < ActiveRecord::Base
  validates_email_format_of :email, :message => "が正しくない形式です。"
  validates_presence_of :email
  validates_length_of :email, :maximum => 200

  validates_presence_of :name
  validates_length_of :name, :maximum => 20

  validates_presence_of :body
  validates_length_of :body, :maximum => 1000
end
