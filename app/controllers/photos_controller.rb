class PhotosController < ApplicationController
  before_filter :find_party
  
  def index
    conditions = {:party_id => @party.id}
    respond_to do |format|
      format.html{
        items_per_page = request.mobile? ? 3 : 10
        @photos = @party.photos.paginate(:order => "id desc", 
                                 :page => params[:page], 
                                 :per_page => items_per_page)
      }
      format.xml{
        @photos = @party.photos.find(:all, :order => "id desc")
        render :layout => false
      }
    end
  end

  def edit_thumbnail
    @photo = @party.photos.find(params[:id])
    img = Magick::Image.read(@photo.thumbnail_path)[0]
    img.rotate!(rotation_param)
    img.format = "JPEG"
    send_data img.to_blob, :type => "image/jpeg", :disposition => "inline"
  end

  def edit
    @photo = @party.photos.find(params[:id])
    @rotate = params[:rotate].to_i
    @right_rotate = (@rotate + 180) % 360 - 90
    @left_rotate = @rotate % 360 - 90
  end

  def update
    @photo = @party.photos.find(params[:id])
    @rotate = params[:rotate].to_i
    img = Magick::Image.read(@photo.path)[0]
    img.rotate!(rotation_param)
    img.format = "JPEG"
    img.write(@photo.path)
    @photo.save_thumbnail
    @photo.save! # 更新日を更新
    flash[:info] = "写真を更新しました。"
    redirect_to :action => "index"
  end

  def zip
    if @party.photos.count > 0
      @party.create_zip unless File.exist?(@party.zip_file)
      redirect_to @party.zip_path
    else
      render :action => "no_photo"
    end
  end

  def destroy
    @party.photos.find(params[:id]).destroy
    flash[:info] = "写真を削除しました。"
    redirect_to :action => "index"
  end

  def confirm_destroy
    @photo = @party.photos.find(params[:id])
  end

  private

  def rotation_param
    params[:rotate].to_i % 360
  end

  def find_party
    @party = Party.find_by_key(params[:party_key])
    unless @party
      render :status => 404, :file => "public/404_party.html"
      return false
    end
  end
end
