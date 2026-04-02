class AddActiveVoyageToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :voyage, :integer
  end
end
