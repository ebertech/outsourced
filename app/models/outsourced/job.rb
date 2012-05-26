module Outsourced
  class Job < ActiveRecord::Base
    cattr_accessor :maximum_job_time
    self.maximum_job_time = 4.hours

    set_table_name "outsourced_jobs"

    belongs_to :outsourced_worker, :class_name => "Outsourced::Worker"
    belongs_to :outsourced_queue, :class_name => "Outsourced::Queue"

    belongs_to :owner, :polymorphic => true

    has_attached_file :payload

    validates :outsourced_queue, :presence => true

    validates :priority, :numericality => {:gteq => 0}
    validates :attempts, :numericality => {:gteq => 0}
    validates :handler_json, :presence => true
    validates :runs_at, :presence => true
    validates :expires_at, :presence => true
    
    scope :stuck, lambda{
      in_progress.where("outsourced_jobs.gets_stuck_at <= ?", Time.now)
    }
    
    scope :expired, lambda{
      in_progress.where("outsourced_jobs.expires_at <= ?", Time.now)
    }
    
    scope :ready_to_run, lambda{
      unassigned.where("outsourced_jobs.runs_at <= ?", Time.now)
    }

    scope :by_priority, order(:priority)
    scope :in_progress, where(:state => ["unassigned", "assigned", "working"])
    scope :unassigned, where(:state => "unassigned")
    scope :for_queues, lambda { |queues|
      where(:outsourced_queue_id => queues.map(&:id))
    }

    before_validation :set_defaults

    def set_defaults
      self.runs_at ||= Time.now
      self.expires_at ||= self.runs_at + self.class.maximum_job_time
    end

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
    
    def handler_object
      #TODO
      #add some callbacks as well
    end

    def to_json
      {
        :id => id,
        :handler_json => handler,
        :has_payload => !!(payload? && payload.exists?)
      }.to_json
    end

    attr_accessor :has_payload
    attr_accessor :backtrace
    attr_accessor :exception

    before_validation :check_for_error

    def check_for_error
      if backtrace.present? && exception.present?
        #TODO write to transition
        self.backtrace = self.exception = nil
        work_failed
      end
    end

    def queue=(queue_name)
      self.outsourced_queue = Outsourced::Queue[queue_name]
    end

    def repeats_on_fail?
      !!repeats_after_fail_at
    end

    def repeats_on_complete?
      !!repeats_after_complete_at
    end

    def handler
      ActiveSupport::JSON.decode(handler_json)
    end

    state_machine :state, :initial => :unassigned do
      event :assign do
        transition :unassigned => :assigned
      end

      event :begin_work do
        transition :assigned => :working
      end

      event :work_failed do
        transition any => :failed, :unless => :repeats_on_fail?
        transition any => :unassigned
      end

      event :reset_job do
        transition any => :unassigned
      end

      event :finished do
        transition :working => :completed, :unless => :repeats_on_complete?
        transition :working => :unassigned
      end

      after_transition :on => :work_failed do |job, transition|
        if job.repeats_after_fail_at
          time_until_next_repeat = job.repeats_after_fail_at - job.runs_at

          job.runs_at = job.repeats_after_fail_at
          job.repeats_after_fail_at = job.runs_at + time_until_next_repeat
          job.save
        end
      end

      after_transition :on => :finished do |job, transition|
        if job.repeats_after_complete_at
          time_until_next_repeat = job.repeats_after_complete_at - job.runs_at
          job.runs_at = job.repeats_after_complete_at
          job.repeats_after_complete_at = job.runs_at + time_until_next_repeat
          job.save
        end
      end

    end
  end
end