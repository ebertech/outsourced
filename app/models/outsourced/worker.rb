module Outsourced
  class Worker < ActiveRecord::Base
    set_table_name "outsourced_workers"

    after_create :reset_tokens!

    has_many :outsourced_jobs, :class_name => "Outsourced::Job", :foreign_key => "outsourced_worker_id"

    has_and_belongs_to_many :outsourced_queues, :class_name => "Outsourced::Queue", :join_table => "outsourced_queues_outsourced_workers", :foreign_key => "outsourced_worker_id", :association_foreign_key => "outsourced_queue_id"

    has_many :tokens, :class_name => "Outsourced::Oauth::OauthToken", :order => "authorized_at desc", :include => [:client_application], :as => :user, :dependent => :destroy

    validates :name, :uniqueness => true, :presence => true

    state_machine :initial => :active do

      after_transition any => :locked do |object, transition|
        object.clear_tokens!
      end

      event :lock_out do
        transition any => :locked
      end

      event :reinstate do
        transition :locked => :active
      end

    end

    def clear_tokens!
      tokens.clear
      save
    end

    def client_application
      Outsourced.client_application
    end

    def current_token
      tokens.first
    end

    def reset_tokens!
      Outsourced::Oauth::AccessToken.transaction do
        clear_tokens!
        Outsourced::Oauth::AccessToken.create(:user => self, :client_application => client_application)
      end
    end

    def available_jobs
      Outsourced::Job.unassigned.for_queues(outsourced_queues).limit(10)
    end

    def reserve_next_job!
      return nil unless active?
      assigned_job = available_jobs.detect do |job|
        job.assign_to!(self)
      end

      return nil unless assigned_job
      assigned_job.begin_work

      assigned_job
    end

    def to_yaml
      {
        :name => name,
        :token => current_token.token,
        :secret => current_token.secret,
        :client_key => client_application.key,
        :client_secret => client_application.secret,
        :url => Outsourced.url
      }.to_yaml
    end

    def works_for?(queue)
      outsourced_queues.include?(queue)
    end
  end
end