class CreateArchiveInstanceForParties < ActiveRecord::Migration
  def self.up
    Party.find(:all).each do |party|
      party.create_archive
      archive = party.archive
      archive.photos_count = party.photos.count
      archive.save!
    end
  end

  def self.down
  end
end
