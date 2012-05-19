class Outsourced::Commands::Worker::Destroy < Outsourced::Commands::Worker::Command
  requires_worker

  def execute
    with_worker(worker_name) do |worker|
      destroy(worker)
    end
  end
end