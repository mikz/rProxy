class CreatePluginVariables < ActiveRecord::Migration
  def self.up
    create_table :plugin_variables do |t|
      t.string :name, :null => false
      t.belongs_to :plugin, :user, :null => false
      t.text :value
      t.timestamps
    end
  end

  def self.down
    drop_table :plugin_variables
  end
end
