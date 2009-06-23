class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.integer :party_id
      t.integer :file_no
      t.text :posted_by

      t.timestamps
    end
  end

  def self.down
    drop_table :photos
  end
end
