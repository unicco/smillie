class PartiesController < ApplicationController
  verify :method => :post, :only => :create
  before_filter :find_party, :only => %w(show info)

  def new
    @party = Party.new
  end

  def create
    @party = Party.new(params[:party])
    if @party.save
      render :action => "create"
    else
      render :action => "new"
    end
  end

  def show
    if request.mobile?
      redirect_to photos_path(:party_key => @party.key)
    else
      # スライドショー
      render :layout => false
    end
  end
  
  def info
  end

  private

  def find_party
    @party = Party.find_by_key(params[:party_key])
    unless @party
      render :status => 404, :file => "public/404_party.html"
      return false
    end
  end
end
