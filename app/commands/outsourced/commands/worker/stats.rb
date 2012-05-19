class Outsourced::Commands::Worker::Stats < Outsourced::Commands::Worker::Command
  def execute
    say ["Name", "Queues", "Number of Jobs"].join("\t")
    workers.each do |worker|
      say [worker.name, worker.outsourced_queues.map(&:name).join(", "), worker.outsourced_jobs.count].join("\t")
    end
  end
end