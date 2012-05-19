class Outsourced::Commands::Queue::Empty < Outsourced::Commands::Queue::Command
  requires_queue

  def execute
    with_queue(queue_name) do |queue|
      queue.empty!
      say "Cleared out #{queue.name}"
    end
  end
end