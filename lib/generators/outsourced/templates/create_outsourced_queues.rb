class CreateOutsourcedQueues < ActiveRecord::Migration
  def change
    create_table :outsourced_queues do |t|
      t.string :name
      t.integer :capacity
    end

    add_index :outsourced_queues, :name, :unique => true
  end
end  