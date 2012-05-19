require 'rails/generators/active_record'

class OutsourcedGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  extend ActiveRecord::Generators::Migration

  class << self
    # Set the current directory as base for the inherited generators.
    def source_root
      @source_root ||= File.expand_path('../templates', __FILE__)
    end

    # Implement the required interface for Rails::Generators::Migration.
    def next_migration_number(dirname) #:nodoc:
      next_migration_number = current_migration_number(dirname) + 1
      ActiveRecord::Migration.next_migration_number(next_migration_number)
    end
  end

  def generate_outsourced_jobs_migration
    #migration_template "create_outsourced_jobs.rb", "db/migrate/create_outsourced_jobs.rb"
  end

  def generate_outsourced_workers_migration
    #migration_template "create_outsourced_workers.rb", "db/migrate/create_outsourced_workers.rb"
  end

  def generate_outsourced_queues_migration
    #migration_template "create_outsourced_queues.rb", "db/migrate/create_outsourced_queues.rb"
  end

  def generate_outsourced_queues_outsourced_workers_migration
    #migration_template "create_outsourced_queues_outsourced_workers.rb", "db/migrate/create_outsourced_queues_outsourced_workers.rb"
  end

  def generate_oauth_migration
    #migration_template "create_oauth_tables.rb", "db/migrate/create_oauth_tables.rb"
  end

  def copy_script
    template 'outsourcer', 'script/outsourcer'
    chmod 'script/outsourcer', 0755
  end
end