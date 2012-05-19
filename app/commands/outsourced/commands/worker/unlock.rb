class Outsourced::Commands::Worker::Unlock < Outsourced::Commands::Worker::Command
  requires_worker

  def execute
    with_worker(worker_name) do |worker|
      if worker.can_reinstate?
        worker.reinstate!
        say "Unlocked #{worker.name}"
      else
        say "Can't unlock #{worker.name}'"
      end
    end
  end
end