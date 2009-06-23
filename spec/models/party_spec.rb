require File.dirname(__FILE__) + '/../spec_helper'

describe Party do
  before(:each) do
    @party = Party.new
    @party.key = "foo"
    @party.title = "bar"
    @party.mail = "info@tinymonkstinymonks.org"
    @party.held_on = Date.today
  end

  it "should be valid" do
    @party.should be_valid
  end

  it "should allow next week" do
    @party.held_on = Date.today + 7
    @party.should be_valid
  end

  it "should not allow yesterday" do
    @party.held_on = Date.today - 1
    @party.should_not be_valid
  end
  
  it "should not allow date later than next week" do
    @party.held_on = Date.today + 8
    @party.should_not be_valid
  end

  it "should not allow reserved key" do
    @party.key = "root"
    @party.should_not be_valid
  end

  it "should not allow key with multiple dots" do
    @party.key = "a.b..c"
    @party.should_not be_valid
  end

  it "should not allow key with 2 characters" do
    @party.key = "ab"
    @party.should_not be_valid
  end

  it "should not allow key beginning with dot" do
    @party.key = ".abc"
    @party.should_not be_valid
  end

  it "should not allow key with 10 characters" do
    @party.key = "abcdeabcde"
    @party.should be_valid
  end

  it "should make key lowercase" do
    @party = Party.new(:key => "FOO")
    @party.key.should == "foo"
  end

  describe "when saving" do
    before do
      Party.delete_all
      @party = Party.new(:key => "foobar", :title => "test", :held_on => Date.today, :mail => "foo@example.com")
    end

    it "should check uniqueness" do
      @party.save!
      next_party = Party.new(:key => "foobar", :title => "test", :held_on => Date.today)
      next_party.should_not be_valid
    end

    it "should check uniqueness in archive" do
      @party.save!
      @party.destroy # destroy した後でも同じ ID は使用不可
      next_party = Party.new(:key => "foobar", :title => "test", :held_on => Date.today)
      next_party.should_not be_valid
    end

    it "should generate qrcode" do
      File.delete(@party.qrcode_file) if File.exist?(@party.qrcode_file)
      File.exist?("#{RAILS_ROOT}/public/qrcodes/foobar/qr.png").should be_false
      @party.save!
      File.exist?("#{RAILS_ROOT}/public/qrcodes/foobar/qr.png").should be_true
    end

    it "should create archive" do
      @party.save!
      archive = @party.archive
      archive.should_not be_nil
      archive.key.should == "foobar"
      PartyArchive.find_by_id(archive.id).should == archive
    end
  end

  describe "with fixtures" do
    fixtures :parties, :party_archives
    
    it "should expire old party" do
      ids = {}
      [:marriage, :old_party, :week_ago, :day_before_week_ago, :demo].each do |name|
        ids[name] = parties(name).id
      end
      Party.expire
      Party.find_by_id(ids[:marriage]).should_not be_nil
      Party.find_by_id(ids[:week_ago]).should_not be_nil
      Party.find_by_id(ids[:day_before_week_ago]).should be_nil
      Party.find_by_id(ids[:old_party]).should be_nil
      
      # demo は有効期限切れにならない
      Party.find_by_id(ids[:demo]).should_not be_nil
    end
  end

  describe "with pictures" do
    fixtures :parties, :party_archives
    
    before do
      @party = parties(:marriage)
      Photo.delete_all
      open("#{File.dirname(__FILE__)}/../fixtures/images/rails.png", "rb") do |f|
        Photo.create!(:file => f, :party => parties(:marriage))
      end
    end

    it "should have photos_count in archive" do
      @party.archive.photos_count.should == 1
    end

    it "should create zip" do
      file = parties(:marriage).create_zip
      File.exist?(file).should be_true
      `unzip -l #{file}`.should =~ / 0001\.jpg/
    end

    describe "when destroying" do
      before do
        @party = parties(:marriage)
        @party.generate_qrcode
        File.directory?(File.dirname(@party.qrcode_file)).should be_true
        File.directory?(@party.image_dir).should be_true
        
        # reload method in an association doesn't work,
        # so we're loading PartyArchive using find method here
        @archive = PartyArchive.find(@party.archive.id)
        
        @party.destroy
      end
      
      it "should keep photos_count in archive" do
        @archive.reload
        @archive.photos_count.should == 1
      end

      it "should clear photos and directories" do
        Photo.count(:conditions => ["party_id=?", @party.id]).should == 0
        File.directory?(File.dirname(@party.qrcode_file)).should be_false
        File.directory?(@party.image_dir).should be_false
      end
    end
  end
end
