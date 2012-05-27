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

    scope :stuck, lambda {
      in_progress.where(arel_table[:gets_stuck_at].lteq(Time.now))
    }

    scope :expired, lambda {
      in_progress.where(arel_table[:expires_at].lteq(Time.now))
    }

    scope :ready_to_run, lambda {
      unassigned.
        where(arel_table[:runs_at].lteq(Time.now)).
        where(arel_table[:expires_at].gt(Time.now))
    }

    IN_PROGRESS_STATES = ["unassigned", "assigned", "working"]

    scope :by_priority, order(:priority)
    scope :in_progress, where(:state => IN_PROGRESS_STATES)

    scope :unassigned, where(:state => "unassigned")

    scope :for_queues, lambda { |queues|
      where(:outsourced_queue_id => queues.map(&:id))
    }

    before_validation :set_defaults

    validate :expires_after_runs, :gets_stuck_after_runs, :expires_after_gets_stuck, :fail_repeat_after_runs, :complete_repeat_after_runs

    def expires_after_runs
      if expires_at && runs_at && expires_at <= runs_at
        errors.add(:expires_at, "can't be before runs_at")
      end
    end

    def gets_stuck_after_runs
      if gets_stuck_at && runs_at && gets_stuck_at <= runs_at
        errors.add(:gets_stuck_at, "can't be before runs_at")
      end
    end

    def expires_after_gets_stuck
      if gets_stuck_at && expires_at && expires_at <= gets_stuck_at
        errors.add(:expires_at, "can't be before gets_stuck_at")
      end
    end

    def fail_repeat_after_runs
      if repeats_after_fail_at && runs_at && repeats_after_fail_at <= runs_at
        errors.add(:repeats_after_fail_at, "can't be before runs_at")
      end
    end

    def complete_repeat_after_runs
      if repeats_after_complete_at && runs_at && repeats_after_complete_at <= runs_at
        errors.add(:repeats_after_complete_at, "can't be before runs_at")
      end
    end

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
        logger.info "Got exception: #{exception}"
        logger.info "Backtrace: #{backtrace}"
        self.exception = self.backtrace = nil
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

    def repeat_after_completion!
      self.class.new(attributes).tap do |job|
        if job.repeats_after_fail_at
          repeat_fail_delta = job.repeats_after_fail_at - job.runs_at
        end

        repeat_complete_delta = job.repeats_after_complete_at - job.runs_at
        expire_delta = job.expires_at - job.runs_at
        job.state = "unassigned"

        job.runs_at = [job.repeats_after_complete_at, Time.now].max
        job.expires_at = job.runs_at + expire_delta
        job.repeats_after_fail_at = job.runs_at + repeat_fail_delta if repeat_fail_delta
        job.repeats_after_complete_at = job.runs_at + repeat_complete_delta

        job.save!
      end
    end

    def repeat_after_failure!
      self.class.new(attributes).tap do |job|
        if job.repeats_after_complete_at
          repeat_complete_delta = job.repeats_after_complete_at - job.runs_at
        end

        repeat_fail_delta = job.repeats_after_fail_at - job.runs_at
        expire_delta = job.expires_at - job.runs_at
        job.state = "unassigned"

        job.runs_at = [job.repeats_after_fail_at, Time.now].max
        job.expires_at = job.runs_at + expire_delta
        job.repeats_after_complete_at = job.runs_at + repeat_complete_delta if repeat_complete_delta
        job.repeats_after_fail_at = job.runs_at + repeat_fail_delta

        job.save!
      end
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

      event :reset_job do
        transition any => :unassigned
      end

      event :work_failed do
        transition any => :failed
      end

      event :work_expired do
        transition IN_PROGRESS_STATES.map(&:to_sym) => :expired
        transition :unassigned => :expired
      end

      event :finished do
        transition :working => :completed
      end


      after_transition :on => [:work_failed, :work_expired] do |job, transition|
        job.repeat_after_failure! if job.repeats_on_fail?
      end

      after_transition :on => :finished do |job, transition|
        job.repeat_after_completion! if job.repeats_on_complete?
      end
    end
  end
end