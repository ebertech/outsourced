class CreateOutsourcedWorkers < ActiveRecord::Migration
  def change
    create_table :outsourced_workers do |t|
      t.string  :name
      t.datetime :last_connected_at
      t.string :state
      t.timestamps
    end
  end
end