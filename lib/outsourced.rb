require "active_support/concern"
require 'paperclip'
require 'state_machine'

module Outsourced
  ApplicationName = "OutsourcedWorker"

  class << self
    def enqueue(job_class, *args)
      options = args.extract_options!
      queue = options.delete(:queue) || Queue::DEFAULT
      puts queue
    end

    alias_method :outsource, :enqueue

    def url
      client_application.url
    end

    def create_client_application!(url)
      Outsourced::Oauth::ClientApplication.create!(:name => ApplicationName, :url => url)
    end

    def client_application
      Outsourced::Oauth::ClientApplication.find_by_name(ApplicationName).tap do |a|
        raise "You must create an application first! Run script/outsourcer init" unless a.present?
      end
    end
  end
end

require 'outsourced/engine.rb'