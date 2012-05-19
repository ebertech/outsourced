class Outsourced::Commands::Queue::Create < Outsourced::Commands::Queue::Command
  requires_queue
  option ["-c","--capacity"], "CAPACITY", "maximum number of jobs, 0 for unlimited", :default => 0

  def execute
    queue = Outsourced::Queue.new(:name => queue_name)
    queue.capacity = capacity
    persist(queue)
  end
end