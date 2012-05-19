require "active_support/concern"
require 'paperclip'
require 'state_machine'

module Outsourced
  class << self
    def enqueue(job_class, *args)
      options = args.extract_options!
      queue = options.delete(:queue) || Queue::DEFAULT
      puts queue
    end

    alias_method :outsource, :enqueue
  end
end

require 'outsourced/engine.rb'