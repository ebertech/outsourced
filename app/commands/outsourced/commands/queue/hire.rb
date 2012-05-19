class Outsourced::Commands::Queue::Hire < Outsourced::Commands::Queue::Command
  requires_queue
  requires_worker

  def execute
    with_queue(queue_name) do |queue|
      with_worker(worker_name) do |worker|
        unless worker.works_for?(queue)
          queue.hire!(worker)
        else
          say "#{worker.name} already works for #{queue.name}"
        end
      end
    end
  end
end