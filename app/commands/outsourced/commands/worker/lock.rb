class Outsourced::Commands::Worker::Lock < Outsourced::Commands::Worker::Command
  requires_worker

  def execute
    with_worker(worker_name) do |worker|
      if worker.can_lock_out?
        worker.lock_out
        say_status :outsourced_worker, "Locked #{worker.name}"
      else
        say_status :outsourced_worker, "Can't lock #{worker.name}", :yellow
      end
    end
  end
end