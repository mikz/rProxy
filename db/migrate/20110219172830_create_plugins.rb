class CreatePlugins < ActiveRecord::Migration
  def self.up
    create_table :plugins do |t|
      t.string :class_name, :name, :url, :null => false
      t.boolean :active, :null => false, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :plugins
  end
end
