class Outsourced::Commands::Queue::Destroy < Outsourced::Commands::Queue::Command
  requires_queue

  def execute
    with_queue(queue_name) do |queue|
      destroy(queue)
    end
  end
end