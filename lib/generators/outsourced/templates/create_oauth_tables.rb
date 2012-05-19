class CreateOauthTables < ActiveRecord::Migration
  def self.up
    create_table :outsourced_client_applications do |t|
      t.string :name
      t.string :url
      t.string :support_url
      t.string :callback_url
      t.string :key, :limit => 40
      t.string :secret, :limit => 40
      t.references :user, :polymorphic => true

      t.timestamps
    end
    add_index :outsourced_client_applications, :key, :unique => true

    create_table :outsourced_oauth_tokens do |t|
      t.references :user, :polymorphic => true
      t.string :type, :limit => 20
      t.integer :client_application_id
      t.string :token, :limit => 40
      t.string :secret, :limit => 40
      t.string :callback_url
      t.string :verifier, :limit => 20
      t.string :scope
      t.timestamp :authorized_at, :invalidated_at, :expires_at
      t.timestamps
    end

    add_index :outsourced_oauth_tokens, :token, :unique => true

    create_table :outsourced_oauth_nonces do |t|
      t.string :nonce
      t.integer :timestamp

      t.timestamps
    end
    add_index :outsourced_oauth_nonces,[:nonce, :timestamp], :unique => true

  end

  def self.down
    drop_table :outsourced_client_applications
    drop_table :outsourced_oauth_tokens
    drop_table :outsourced_oauth_nonces
  end

end
