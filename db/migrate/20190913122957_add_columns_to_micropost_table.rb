class AddColumnsToMicropostTable < ActiveRecord::Migration[5.1]
  def change
    add_column :microposts, :price, :float
    add_column :microposts, :rating, :float
    add_column :microposts, :latitude, :float
    add_column :microposts, :longitutde, :float
    add_column :microposts, :country, :string
    add_column :microposts, :city, :string
  end
end
