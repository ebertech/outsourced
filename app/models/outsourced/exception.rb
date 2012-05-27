require 'tempfile'
module Outsourced
  class Exception < ActiveRecord::Base
    set_table_name "outsourced_exceptions"
    has_attached_file :context

    belongs_to :outsourced_job, :class_name => "::Outsourced::Job", :foreign_key => :outsourced_job_id
    validates :outsourced_job, :presence => true
    validates :type_name, :presence => true
    validates :time, :presence => true
    validates :message, :presence => true

    class << self
      def from_hash!(attributes)
        Tempfile.open("outsourced_exception_ctx") do |f|
          new.tap do |exception|
            exception.type_name = attributes[:type_name] || "Exception"
            exception.message = attributes[:message] || "Got an exception"
            exception.time = attributes[:time] || Time.now
            exception.outsourced_job = attributes[:outsourced_job]
            f.write(attributes.to_yaml)
            f.flush
            exception.context = f
            exception.save!
          end
        end
      end
    end
  end
end
