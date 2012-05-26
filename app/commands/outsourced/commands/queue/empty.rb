class Outsourced::Commands::Queue::Empty < Outsourced::Commands::Queue::Command
  requires_queue

  def execute
    with_queue(queue_name) do |queue|
      queue.empty!
      say_status :outsourced_queue, "Cleared out #{queue.name}"
    end
  end
end