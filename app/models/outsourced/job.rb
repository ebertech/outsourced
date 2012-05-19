module Outsourced
  class Job < ActiveRecord::Base
    set_table_name "outsourced_jobs"

    belongs_to :outsourced_worker, :class_name => "Outsourced::Worker"
    belongs_to :outsourced_queue, :class_name => "Outsourced::Queue"

    belongs_to :owner, :polymorphic => true

    has_attached_file :payload

    validates :outsourced_queue, :presence => true

    validates :priority, :numericality => {:gteq => 0}
    validates :attempts, :numericality => {:gteq => 0}

    scope :in_progress, where(:state => ["unassigned", "assigned", "working", "failed"])
    scope :unassigned, where(:state => "unassigned")
    scope :for_queues, lambda{|queues|
      where(:outsourced_queue_id => queues.map(&:id))
    }

    def assign_to!(worker)
      changed = self.class.update_all({:outsourced_worker_id => worker.id}, {:id => id})
      if changed == 1
        self.outsourced_worker = worker
        self.state = :assigned
        true
      else
        false
      end
    end

    state_machine :state, :initial => :unassigned do
      event :assign do
        transition :unassigned => :assigned
      end

      event :begin_work do
        transition :assigned => :working
      end

      event :work_failed do
        transition any => :failed
      end

      event :finished do
        transition :working => :completed
      end
    end
  end
end