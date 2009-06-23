require File.dirname(__FILE__) + '/../spec_helper'

describe Photo do
  fixtures :parties, :party_archives

  before(:each) do
    @photo = Photo.new(:party => parties(:marriage))
  end

  it "should be valid" do
    @photo.should be_valid
  end

  describe "when saving" do
    before do
      @zipfile = "#{RAILS_ROOT}/tmp/test.zip"
      @party = parties(:marriage)
      
      @party.stub!(:zip_file).and_return(@zipfile)
      open(@zipfile, "w"){}
      File.exist?(@zipfile).should be_true

      open("#{File.dirname(__FILE__)}/../fixtures/images/rails.png", "rb") do |f|
        @photo = Photo.new(:party => @party, :file => f)
        @photo.save!
      end
    end

    it "should increment count in archive" do
      @photo.party.archive.photos_count.should == 1
    end

    it "should load file" do
      @photo.file_no.should == 1
      @photo.filename.should == "0001.jpg"
      File.exist?(File.join(@party.image_dir, "0001.jpg")).should be_true
    end

    it "should save thumbnail" do
      @photo.thumbnail_path.should =~ /thumbnails\/0001\.jpg/
      File.exist?(@photo.thumbnail_path).should be_true
    end

    it "should remove zipfile" do
      File.exist?(@zipfile).should be_false
    end

    it "should be deletable" do
      @party.create_zip
      File.exist?(@zipfile).should be_true
      @photo.destroy
      File.exist?(@zipfile).should be_false
      File.exist?(@photo.thumbnail_path).should be_false
      File.exist?(@photo.path).should be_false
    end
  end

  describe "when saving large image" do
    before do
      @zipfile = "#{RAILS_ROOT}/tmp/test.zip"
      @party = parties(:marriage)
      @party.stub!(:zip_file).and_return(@zipfile)
      open("#{File.dirname(__FILE__)}/../fixtures/images/large_image.jpg", "rb") do |f|
        @photo = Photo.new(:party => @party, :file => f)
        @photo.save!
      end
    end
    
    it "should resize image" do
      @photo.file_no.should == 1
      @photo.filename.should == "0001.jpg"
      img = Magick::Image.read(File.join(@party.image_dir, "0001.jpg"))[0]
      img.columns.should == 1024
      img.rows.should == 1024 * 3 / 4
    end
  end
end
