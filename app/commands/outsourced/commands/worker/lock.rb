class Outsourced::Commands::Worker::Lock < Outsourced::Commands::Worker::Command
  requires_worker

  def execute
    with_worker(worker_name) do |worker|
      worker.lock!
      say "Locked #{worker.name}"
    end
  end
end