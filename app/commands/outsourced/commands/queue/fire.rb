class Outsourced::Commands::Queue::Fire < Outsourced::Commands::Queue::Command
  requires_queue
  requires_worker

  def execute
    with_queue(queue_name) do |queue|
      with_worker(worker_name) do |worker|
        if worker.works_for?(queue)
          queue.fire!(worker)
          say "#{worker.name} no longer works for #{queue.name}"
        else
          say "#{worker.name} does not work for #{queue.name}"
        end
      end
    end
  end
end