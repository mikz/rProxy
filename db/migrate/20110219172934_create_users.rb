class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.database_authenticatable
      t.confirmable
      t.recoverable
      t.rememberable
      t.trackable
      
      t.string :salt, :proxy_key, :length => 256, :null => false
      t.boolean :admin, :null => false, :default => false
      t.timestamps
    end
#    add_index :users, :email, :unique => true
    execute %{
      ALTER TABLE users ALTER COLUMN email DROP DEFAULT;
    }
  end

  def self.down
    drop_table :users
  end
end
