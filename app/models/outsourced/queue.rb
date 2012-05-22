module Outsourced
  class Queue < ActiveRecord::Base
    set_table_name "outsourced_queues"

    DEFAULT = "delayed_job"

    has_many :outsourced_jobs, :class_name => "::Outsourced::Job", :foreign_key => "outsourced_queue_id"
    has_and_belongs_to_many :outsourced_workers, :class_name => "Outsourced::Worker", :join_table => "outsourced_queues_outsourced_workers", :association_foreign_key => "outsourced_worker_id", :foreign_key => "outsourced_queue_id"

    def enqueue(job_class, *args_and_options)
      options = args_and_options.extract_options!
      job_class = case job_class
                    when Class
                      job_class.name
                    else
                      job_class.to_s
                  end
      raise "At capacity" if !capacity.zero? && outsourced_jobs.in_progress.count >= capacity
      params = {}
      params[:outsourced_queue] =self
      params[:handler_json] = {
        :class => job_class.to_s,
        :args => args_and_options
      }.to_json
      params[:payload] = options[:payload] if options.key?(:payload)

      outsourced_jobs.create(params)
    end

    class << self
      def [](name)
        find_or_create_by_name(name)
      end
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