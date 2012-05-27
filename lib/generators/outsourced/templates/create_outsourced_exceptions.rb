class CreateOutsourcedExceptions < ActiveRecord::Migration
  def change
    create_table :outsourced_exceptions do |t|
      t.references :outsourced_job
      t.string :type_name
      t.string :message
      t.datetime :time

      t.string :context_file_name
      t.integer :context_size
      t.string :context_content_type
      t.string :context_fingerprint
      t.datetime :context_updated_at

      t.timestamps
    end

    add_index :outsourced_exceptions, :outsourced_job_id
  end
end