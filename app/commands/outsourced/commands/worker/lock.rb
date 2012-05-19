class Outsourced::Commands::Worker::Lock < Outsourced::Commands::Worker::Command
  requires_worker

  def execute
    with_worker(worker_name) do |worker|
      if worker.can_lock_out?
        worker.lock_out
        say "Locked #{worker.name}"
      else
        say "Can't lock #{worker.name}'"
      end
    end
  end
end