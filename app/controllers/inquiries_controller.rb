class InquiriesController < ApplicationController

  def new
    @inquiry = Inquiry.new
    respond_to do |format|
      format.html
    end
  end
  
  def create
    @inquiry = Inquiry.new(params[:inquiry])
    respond_to do |format|
      if @inquiry.save
        Notifier.deliver_inquiry_for_user @inquiry
        Notifier.deliver_inquiry_for_admin @inquiry
        format.html { inquiries_path }
      else
        format.html { render :action => "new" }
      end
    end
  end
end
