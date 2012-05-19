module Outsourced
  class Worker < ActiveRecord::Base
    set_table_name "outsourced_workers"

    has_many :outsourced_jobs, :class_name => "Outsourced::Job", :foreign_key => "outsourced_worker_id"
    has_and_belongs_to_many :outsourced_queues, :class_name => "Outsourced::Queue", :join_table => "outsourced_queues_outsourced_workers", :foreign_key => "outsourced_worker_id", :association_foreign_key => "outsourced_queue_id"

    validates :name, :uniqueness => true, :presence => true

    state_machine :initial => :active do

      event :lock_out do
        transition any => :locked
      end

      event :reinstate do
        transition :locked => :active
      end

    end

    def reset!
      
    end

    def reserve_next_job!
      #TODO query
    end

    def to_yaml
      #TODO
    end

    def works_for?(queue)
      outsourced_queues.include?(queue)
    end
  end
end