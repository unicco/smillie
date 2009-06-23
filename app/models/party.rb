begin
  require "qrcode_img"
rescue LoadError
  RAILS_DEFAULT_LOGGER.error "Failed to load qrcode_img: #{$!}"
end
require "fileutils"
require "nkf"

class Party < ActiveRecord::Base
  validates_presence_of :key
  validates_presence_of :mail
  validates_presence_of :title
  validates_presence_of :held_on
  validates_length_of :key, :in => 3..20, :allow_blank => true
  validates_exclusion_of :key, :in => %w(create new parties mailer-daemon postmaster root admin index help about mobile images javascripts stylesheets daemon nobody info smillie qrcodes home photos system flv flash casestudy donation download)
  validates_format_of :key, :with => /^[a-z0-9]+([a-z0-9\-][a-z0-9]+)*$/, :allow_blank => true
  validates_email_format_of :mail, :message => "が正しくない形式です。"
  validate_on_create :validate_key_uniqueness
  validate_on_create :validate_held_on

  after_save :generate_qrcode
  before_create :create_archive

  after_destroy :destroy_files

  has_many :photos # photos are destroyed in Party#destroy
  has_one :archive, :class_name => "PartyArchive", :dependent => :nullify

  # 有効期限切れにならないキーの一覧
  DEMO_KEYS = %w(demo kohiyama)

  # 有効期間
  VALID_DATES = 7

  def key=(key)
    write_attribute(:key, key.to_s.downcase)
  end

  def image_dir
    File.join(RAILS_ROOT, "public", "photos", key)
  end

  def photo_location
    "/photos/#{key}"
  end

  def qrcode_path
    "/qrcodes/#{key}/qr.png"
  end

  def zip_path
    "#{photo_location}/#{key}.zip"
  end

  def qrcode_file
    File.join(RAILS_ROOT, "public", "qrcodes", key, "qr.png")
  end

  def zip_file
    File.join(image_dir, "#{key}.zip")
  end

  def mail_addr
    "#{key}@#{APP_DOMAIN}"
  end

  def generate_qrcode
    begin
      FileUtils.mkdir_p(File.dirname(qrcode_file))
      qr = Qrcode_image.new
      qr.qrcode_image_out(NKF.nkf("-Ws", <<-EOS), "png", qrcode_file)
ここに写真を送ってね→ #{mail_addr}
ここで写真を見られるよ→ http://#{APP_DOMAIN}/#{key}/photos
EOS
    rescue
      logger.error "Failed to generate qrcode: #{$!}"
    end
  end

  def create_archive
    self.archive = PartyArchive.new(:title => title,
                                    :key => key,
                                    :held_on => held_on,
                                    :photos_count => 0)
  end

  def lock_zip
    FileUtils.mkdir_p(image_dir)
    open(File.join(image_dir, "lockfile"), "w") do |lockfile|
      lockfile.flock(File::LOCK_EX)
      yield
    end
  end

  def delete_zip
    lock_zip do
      File.unlink(zip_file) if File.exist?(zip_file)
    end
  end

  def create_zip
    lock_zip do
      # 念のため key から英数字以外を削除
      tmpfile = "#{image_dir}/#{key.gsub(/[^0-9a-z-]/,'')}.zip.tmp"
      logger.info `zip -j #{tmpfile} #{image_dir}/*.jpg`
      raise "failed to create zip" if $?.to_i != 0
      FileUtils.mv tmpfile, zip_file
      zip_file
    end
  end

  def destroy_files
    FileUtils.rm_r(image_dir) if File.exist?(image_dir)
    FileUtils.rm_r(File.dirname(qrcode_file)) if File.exist?(qrcode_file)
  end
  
  def destroy
    photos.find(:all).each do |photo|
      photo.destroy_without_decrement
    end
    super
  end

  def validate_key_uniqueness
    Party.lock_table do
      if Party.find_by_key(key) || PartyArchive.find_by_key(key)
        errors.add :key, N_("指定された%{fn}は既に使用されています。別の%{fn}を指定してください。")
      end
    end
  end

  def validate_held_on
    if held_on < Date.today || Date.today + 7 < held_on
      errors.add :held_on, N_("%{fn}は本日から7日以内を指定してください。")
    end
  end

  class << self
    def expire
      find(:all, 
           :conditions => ["key not in (?) and held_on + ? < ?", 
                           DEMO_KEYS, VALID_DATES, Date.today]).each do |party|
        logger.info "Destroying party: #{party.key}"
        party.destroy
      end
    end

    def lock_table(&block)
      transaction do
        connection.execute "lock table #{table_name} in share row exclusive mode"
        yield
      end
    end
  end
end
