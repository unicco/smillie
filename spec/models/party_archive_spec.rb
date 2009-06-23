require File.dirname(__FILE__) + '/../spec_helper'

describe PartyArchive do
  before(:each) do
    @party = PartyArchive.new
    @party.key = "foo"
    @party.title = "bar"
    @party.held_on = Date.today
  end

  it "should be valid" do
    @party.should be_valid
  end
end
