module Outsourced
  class Maintenance
    def perform(*args)
      Outsourced::Job.expired.each(&:work_expired)
    end
  end
end