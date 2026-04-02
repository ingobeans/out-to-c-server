class CreateVoyages < ActiveRecord::Migration[8.1]
  def change
    create_table :voyages do |t|
      t.string :name
      t.string :desc
      t.float :hours
      t.string :cargo
      t.string :hackatime
      t.string :repo

      t.timestamps
    end
  end
end
