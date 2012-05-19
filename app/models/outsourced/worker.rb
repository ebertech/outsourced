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

    def reset_tokens!
      Outsourced::Oauth::AccessToken.transaction do
        clear_tokens!
        Outsourced::Oauth::AccessToken.create(:user => self, :client_application => client_application)
      end
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