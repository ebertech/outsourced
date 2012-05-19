class Outsourced::Commands::Worker::Reset < Outsourced::Commands::Worker::Command
  requires_worker

  def execute
    with_worker(worker_name) do |worker|
      worker.reset_tokens!
      say "Reset #{worker.name}"
    end
  end
end