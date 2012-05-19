class Outsourced::Commands::Worker::Config < Outsourced::Commands::Worker::Command
  requires_worker

  def execute
    with_worker(worker_name) do |worker|
      puts worker.to_yaml
    end
  end
end