class AddPartyMail < ActiveRecord::Migration
  def self.up
    add_column :parties, :mail, :string
  end

  def self.down
    remove_column :parties, :mail
  end
end
