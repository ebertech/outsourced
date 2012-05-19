module Outsourced
  class Job < ActiveRecord::Base
    set_table_name "outsourced_jobs"

    belongs_to :outsourced_worker
    belongs_to :outsourced_queue

    belongs_to :owner, :polymorphic => true

    has_attached_file :payload

    validates :outsourced_queue, :presence => true

    validates :priority, :numericality => {:gteq => 0}
    validates :attempts, :numericality => {:gteq => 0}


    state_machine :state, :initial => :pending do
      #TODO
    end
  end
end