class Outsourced::Commands::Worker::Unlock < Outsourced::Commands::Worker::Command
  requires_worker

  def execute
    with_worker(worker_name) do |worker|
      worker.unlock!
      say "Unlocked #{worker.name}"
    end
  end
end