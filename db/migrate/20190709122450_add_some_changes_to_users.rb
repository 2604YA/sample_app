class AddSomeChangesToUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :reset_digest, :string
    remove_column :users, :reset_sent_at, :datatime
    remove_column :users, :reset_sent_at, :datetime
  
    add_column :users, :reset_digest, :string
    add_column :users, :reset_sent_at, :datetime
  end
end
