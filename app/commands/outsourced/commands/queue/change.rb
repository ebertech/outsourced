class Outsourced::Commands::Queue::Change < Outsourced::Commands::Queue::Command
  requires_queue

  option ["-c","--capacity"], "CAPACITY", "maximum number of jobs, 0 for unlimited", :default => 0

  def execute
    with_queue(queue_name) do |queue|
      queue.capacity = capacity
      update(queue)
    end
  end
end