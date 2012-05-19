class Outsourced::Commands::Worker::Create < Outsourced::Commands::Worker::Command
  requires_worker

  def execute
    worker = Outsourced::Worker.new(:name => worker_name)

    persist(worker)
  end
end