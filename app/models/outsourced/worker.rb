module Outsourced
  class Worker < ActiveRecord::Base
    set_table_name "outsourced_workers"

    has_many :outsourced_jobs, :class_name => "Outsourced::Job", :foreign_key => "outsourced_worker_id"
    has_and_belongs_to_many :outsourced_queues, :class_name => "Outsourced::Queue", :join_table => "outsourced_queues_outsourced_workers", :foreign_key => "outsourced_worker_id", :association_foreign_key => "outsourced_queue_id"

    has_many :client_applications, :as => :user, :class_name => "Outsourced::Oauth::ClientApplication"
    has_many :tokens, :class_name => "Outsourced::Oauth::OauthToken", :order => "authorized_at desc", :include => [:client_application], :as => :user

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
      #TODO
    end

    def reserve_next_job!
      return nil unless is_active?
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