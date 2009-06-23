require File.dirname(__FILE__) + '/../spec_helper'

describe PartiesController do
  integrate_views

  #Delete this example and add some real ones
  it "should use PartiesController" do
    controller.should be_an_instance_of(PartiesController)
  end

  it "should instantiate party and render 'parties/new' on GET to new" do
    party = mock_model(Party)
    party.should_receive(:held_on).and_return(nil)
    party.should_receive(:title).and_return(nil)
    party.should_receive(:key).and_return(nil)
    party.should_receive(:mail).and_return(nil)
    
    Party.should_receive(:new).and_return(party)

    get 'new'
    response.should render_template(:new)
  end

  it "should be missing when party does not exist" do
    party = mock_model(Party)
    Party.should_receive(:find_by_key).and_return(nil)
    get "show", :party_key => "foobar"
    response.should be_missing
  end

  it "should create party" do
    Party.delete_all
    PartyArchive.delete_all
    date = Date.today
    post "create", :party => {:key => "marriage", 
      :title => "hello", 
      :mail => "foo@example.com",
      "held_on(1i)" => "#{date.year}", 
      "held_on(2i)" => "#{date.month}", 
      "held_on(3i)" => "#{date.day}"}
    response.should render_template(:create)
  end

  describe "with party prepared" do
    integrate_views

    before do
      @party = mock_model(Party)
      @party.stub!(:key).and_return("marriage")
      @party.stub!(:title).and_return("けこんしき")
      @party.stub!(:mail_addr).and_return("marriage@smillie.jp")
      @party.stub!(:qrcode_path).and_return("/qrcode.png")
      @party.stub!(:held_on).and_return(Date.today)
      Party.should_receive(:find_by_key).and_return(@party)
    end

    it "should show party" do
      get "show", :party_key => "marriage"
      assigns(:party).should == @party
      response.should render_template(:show)
    end

    it "should redirect to info when mobile" do
      @request.stub!(:mobile).and_return(Jpmobile::Mobile::Docomo.new(controller))
      @request.stub!(:mobile?).and_return(true)
      get "show", :party_key => "marriage"
      response.should be_redirect
    end

    it "should show party info" do
      get "info", :party_key => "marriage"
      response.should render_template(:info)
    end
  end
end
