class Outsourced::Commands::Queue::Hire < Outsourced::Commands::Queue::Command
  requires_queue
  requires_worker

  def execute
    with_queue(queue_name) do |queue|
      with_worker(worker_name) do |worker|
        unless worker.works_for?(queue)
          queue.hire!(worker)
          say_status :outsourced_queue, "#{worker.name} now works for #{queue.name}"
        else
          say_status :outsourced_queue, "#{worker.name} already works for #{queue.name}", :yellow
        end
      end
    end
  end
end