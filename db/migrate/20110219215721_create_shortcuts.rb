class CreateShortcuts < ActiveRecord::Migration
  def self.up
    create_table :shortcuts do |t|
      t.text :query, :null => false
      t.belongs_to :user, :null => false
      t.belongs_to :plugin, :null => false
      t.string :name, :null => false
      t.text :note

      t.timestamps
    end
    add_index :shortcuts, :query, :unique => true
  end

  def self.down
    drop_table :shortcuts
  end
end
