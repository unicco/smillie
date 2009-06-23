require "RMagick"
require "fileutils"

class Photo < ActiveRecord::Base
  belongs_to :party
  attr_accessor :file

  before_create :save_to_file
  before_create :save_thumbnail
  after_save :delete_zipfile
  after_save :increment_photos_count

  after_destroy :delete_zipfile
  after_destroy :delete_file
  after_destroy :decrement_photos_count

  validates_presence_of :party

  THUMB_WIDTH = 160
  THUMB_HEIGHT = 120

  # 縦または横の最大の大きさ
  MAX_SIDE_SIZE = 1024

  def save_to_file
    connection.execute "lock table photos in share row exclusive mode"
    max_file_no = connection.select_value("select max(file_no) from photos where party_id=#{party.id}").to_i
    self.file_no = max_file_no + 1

    data = file.read
    image = Magick::Image.from_blob(data)[0]
    FileUtils.mkdir_p(party.image_dir)
    if "JPEG" != image.format || image.columns > MAX_SIDE_SIZE || image.rows > MAX_SIDE_SIZE
      image.format = "JPEG"
      if image.columns > MAX_SIDE_SIZE || image.rows > MAX_SIDE_SIZE
        image.resize_to_fit!(MAX_SIDE_SIZE, MAX_SIDE_SIZE)
      end
      image.write(path)
    else
      open(path, "wb"){|f|f.write(data)}
    end
  end

  def save_thumbnail
    image = Magick::Image.read(path)[0]
    FileUtils.mkdir_p(File.dirname(thumbnail_path))
    image.resize_to_fit!(THUMB_WIDTH, THUMB_HEIGHT)
    image.write(thumbnail_path)
  end

  def thumbnail_path
    File.join(party.image_dir, "thumbnails", filename)
  end

  def location
    "#{party.photo_location}/#{filename}"
  end

  def thumbnail_location
    # 更新後はキャッシュを読まないように更新日をURLに含める
    "#{party.photo_location}/thumbnails/#{filename}?#{updated_at.to_i}"
  end

  def path
    File.join(party.image_dir, filename)
  end

  def filename
    "%04d.jpg" % file_no
  end

  def delete_file
    File.delete(path) if File.exist?(path)
    File.delete(thumbnail_path) if File.exist?(thumbnail_path)
  end

  def delete_zipfile
    party.delete_zip
  end

  def destroy_without_decrement
    @dont_decrement = true
    destroy
  end

  def increment_photos_count
    if party.archive
      PartyArchive.increment_counter(:photos_count, party.archive.id)
      party.archive.reload
    end
  end

  def decrement_photos_count
    if !@dont_decrement && party.archive
      PartyArchive.decrement_counter(:photos_count, party.archive.id)
      party.archive.reload
    end
  end
end
