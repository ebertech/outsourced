class Outsourced::Commands::Queue::Stats < Outsourced::Commands::Queue::Command
  def execute
    say ["Name", "Capacity", "Number of Jobs", "Number of Workers"].join("\t")
    queues.each do |queue|
      say [queue.name, queue.capacity, queue.outsourced_jobs.count, queue.outsourced_workers.count].join("\t")
    end
  end
end