require File.dirname(__FILE__) + '/../spec_helper'

describe PhotosController do
  before do
    @party = mock_model(Party)
    @party.stub!(:key).and_return("foobar")
    @party.stub!(:mail_addr).and_return("foobar@smillie.jp")
    @party.stub!(:qrcode_path).and_return("foobar/qrcode.png")
    @party.stub!(:photos).and_return(Photo)
    @party.stub!(:zip_file).and_return("#{RAILS_ROOT}/tmp/test.zip")
    @party.stub!(:zip_path).and_return("/test.zip")
    @party.stub!(:title).and_return("ふーばー")
  end

  #Delete these examples and add some real ones
  it "should use PhotosController" do
    controller.should be_an_instance_of(PhotosController)
  end

  def prepare_photos
    p1 = mock_model(Photo)
    p1.stub!(:filename).and_return("0001.jpg")
    p1.stub!(:thumbnail_location).and_return("/thumbs/0001.jpg")
    p1.stub!(:location).and_return("/0001.png")
    img_src = "#{File.dirname(__FILE__)}/../fixtures/images/rails.png"
    p1.stub!(:thumbnail_path).and_return("#{RAILS_ROOT}/tmp/photo.png")
    p1.stub!(:path).and_return("#{RAILS_ROOT}/tmp/photo.png")
    FileUtils.cp img_src, p1.path
    p1.stub!(:created_at).and_return(Time.now)
    p1.stub!(:id).and_return(1)

    p2 = mock_model(Photo)
    p2.stub!(:filename).and_return("0002.jpg")
    p2.stub!(:thumbnail_location).and_return("/thumbs/0002.jpg")
    p2.stub!(:created_at).and_return(Time.now)
    p2.stub!(:id).and_return(2)

    @photos = [p1, p2]
    Photo.stub!(:find).and_return(@photos)
    Photo.stub!(:count).and_return(@photos.size)
    Party.should_receive(:find_by_key).and_return(@party)
  end

  describe "GET photos with views integrated" do
    integrate_views
    
    before do
      prepare_photos
    end

    it "xml should be successful" do
      get 'index', :format => "xml", :party_key => @party.key
      response.should be_success
    end

    it "html should be successful" do
      get 'index', :party_key => @party.key
      response.should be_success
    end

    after do
      response.body.should =~ /0001\.jpg/
      assigns(:photos).should_not be_nil
      assigns(:party).should_not be_nil
    end
  end

  describe "without any photo" do
    integrate_views

    before do
      Party.should_receive(:find_by_key).and_return(@party)
      Photo.stub!(:find).and_return([])
      Photo.stub!(:count).and_return(0)
    end
    
    it "zip should show error" do
      get 'zip', :party_key => @party.key
      response.should render_template(:no_photo)
    end
  end

  describe "with photos prepared" do
    integrate_views

    before do
      prepare_photos
    end

    it "zip should create file and redirect when file does not exist" do
      File.unlink(@party.zip_file) if File.exist?(@party.zip_file)
      
      @party.should_receive(:create_zip).and_return("test.zip")
      get 'zip', :party_key => @party.key
      response.should be_redirect
    end

    it "zip should just redirect when file exists" do
      open(@party.zip_file, "wb"){|f| }

      @party.should_not_receive(:create_zip)
      get 'zip', :party_key => @party.key
      response.should be_redirect
    end
  end

  describe "with single photo prepared" do
    integrate_views

    before do
      prepare_photos
      @photo = @photos[0]
      Photo.should_receive(:find).with(@photo.id.to_s).and_return(@photo)
    end

    it "edit should be successful and assign rotation" do
      get 'edit', :party_key => @party.key, :id => @photo.id
      assigns(:right_rotate).should == 90
      assigns(:left_rotate).should == -90
      response.should render_template(:edit)
    end

    it "edit should be successful and assign rotation from 90 degrees" do
      get 'edit', :party_key => @party.key, :id => @photo.id, :rotate => 90
      assigns(:right_rotate).should == 180
      assigns(:left_rotate).should == 0
      response.should render_template(:edit)
    end

    it "edit should be successful and assign rotation from -90 degrees" do
      get 'edit', :party_key => @party.key, :id => @photo.id, :rotate => -90
      assigns(:right_rotate).should == 0
      assigns(:left_rotate).should == 180
      response.should render_template(:edit)
    end

    it "edit should be successful and assign rotation from 180 degrees" do
      get 'edit', :party_key => @party.key, :id => @photo.id, :rotate => 180
      assigns(:right_rotate).should == -90
      assigns(:left_rotate).should == 90
      response.should render_template(:edit)
    end

    it "edit_thumbnail should be successful" do
      get 'edit_thumbnail', :party_key => @party.key, :id => @photo.id, :rotate => "90"
      data = response.body
      img = Magick::Image.from_blob(data)[0]
      # 50x64 -> 64x50 に回転
      img.rows.should == 50
      img.columns.should == 64
    end

    it "should update photo with rotation" do
      @photo.should_receive(:save_thumbnail)
      @photo.should_receive(:save!)
      post 'update', :party_key => @party.key, :id => @photo.id, :rotate => "-90"
      img = Magick::Image.read(@photo.path)[0]
      # 50x64 -> 64x50 に回転
      img.rows.should == 50
      img.columns.should == 64
      response.should be_redirect
    end

    it "should update photo with huge rotation value" do
      @photo.should_receive(:save_thumbnail)
      @photo.should_receive(:save!)
      time = Time.now
      post 'update', :party_key => @party.key, :id => @photo.id, :rotate => "3600000000090"
      (Time.now - time).should < 3
      img = Magick::Image.read(@photo.path)[0]
      # 50x64 -> 64x50 に回転
      img.rows.should == 50
      img.columns.should == 64
      response.should be_redirect
    end

    it "should destroy photo" do
      @photo.should_receive(:destroy)
      post 'destroy', :party_key => @party.key, :id => @photo.id
      response.should be_redirect
    end

    it "should confirm destroying photo" do
      post 'confirm_destroy', :party_key => @party.key, :id => @photo.id
      response.should render_template(:confirm_destroy)
    end
  end
end
