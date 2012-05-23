class CreateOutsourcedJobs < ActiveRecord::Migration
  def change
    create_table :outsourced_jobs do |t|
      t.integer :priority, :default => 0, :null => false
      t.integer :attempts, :default => 0, :null => false

      t.references :outsourced_worker
      t.references :outsourced_queue
      t.references :owner, :polymorphic => true

      t.string  :state
      t.text    :handler_json

      t.string :payload_file_name
      t.integer :payload_size
      t.string :payload_content_type
      t.string :payload_fingerprint
      t.datetime :payload_updated_at
      
      t.datetime :runs_at
      t.datetime :gets_stuck_at
      t.datetime :expires_at
      t.datetime :repeats_after_fail_at
      t.datetime :repeats_after_complete_at

      t.timestamps
    end

    add_index :outsourced_jobs, [:priority, :outsourced_worker_id]
  end
end