class CreateOutsourcedQueuesOutsourcedWorkers < ActiveRecord::Migration
  def change
    create_table :outsourced_queues_outsourced_workers, :id => false do |t|
      t.references :outsourced_worker
      t.references :outsourced_queue
    end
    add_index :outsourced_queues_outsourced_workers, [:outsourced_worker_id, :outsourced_queue_id], :name => :outsourced_queues_outsourced_workers_index
  end
end