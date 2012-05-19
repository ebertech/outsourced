module Outsourced
  class Queue < ActiveRecord::Base
    set_table_name "outsourced_queues"

    DEFAULT = "delayed_job"

    has_many :outsourced_jobs, :class_name => "Outsourced::Job", :foreign_key => "outsourced_queue_id"
    has_and_belongs_to_many :outsourced_workers, :class_name => "Outsourced::Worker", :join_table => "outsourced_queues_outsourced_workers", :association_foreign_key => "outsourced_worker_id", :foreign_key => "outsourced_queue_id"

    def enqueue(*args)
      raise "At capacity" if !capacity.zero? && outsourced_jobs.in_progress.count >= capacity
      outsourced_jobs.create(:outsourced_queue => self)
    end

    validates :capacity, :numericality => {:gte => 0}
    validates :name, :uniqueness => true, :presence => true

    def hire!(worker)
      outsourced_workers << worker unless worker.works_for?(self)
    end

    def fire!(worker)
      outsourced_workers.delete(worker) if worker.works_for?(self)
    end

    def empty!
      outsourced_jobs.clear
    end
  end
end