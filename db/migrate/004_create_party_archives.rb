class CreatePartyArchives < ActiveRecord::Migration
  def self.up
    create_table :party_archives do |t|
      t.integer :party_id
      t.text :title
      t.string :key
      t.date :held_on
      t.integer :photos_count

      t.timestamps
    end
#    Party.find(:all).each do |party|
#      party.create_archive
#    end
  end

  def self.down
    drop_table :party_archives
  end
end
