class HomeController < ApplicationController
  def index
    @count = PartyArchive.sum(:photos_count)
  end
  
  def donation
  end
end
