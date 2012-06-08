class CreatePluginSettings < ActiveRecord::Migration
  def self.up
    create_table :plugin_settings do |t|
      t.string :name, :null => false
      t.belongs_to :plugin, :user, :null => false
      t.text :value
      t.timestamps
    end
  end

  def self.down
    drop_table :plugin_settings
  end
end
