class Outsourced::Commands::Worker::Unlock < Outsourced::Commands::Worker::Command
  requires_worker

  def execute
    with_worker(worker_name) do |worker|
      if worker.can_reinstate?
        worker.reinstate!
        say_status :outsourced_worker, "Unlocked #{worker.name}"
      else
        say_status :outsourced_worker,"Can't unlock #{worker.name}", :yellow
      end
    end
  end
end