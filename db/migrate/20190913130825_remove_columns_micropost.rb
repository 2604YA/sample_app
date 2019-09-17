class RemoveColumnsMicropost < ActiveRecord::Migration[5.1]
  def change
    remove_column :microposts, :price
    remove_column :microposts, :rating
  end
end
