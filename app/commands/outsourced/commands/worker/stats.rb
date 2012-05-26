class Outsourced::Commands::Worker::Stats < Outsourced::Commands::Worker::Command
  def execute
    say "Worker Statistics"

    table = [["Name", "Number of Queues", "Number of Jobs"]]
    workers.each do |worker|
      table << [worker.name, worker.outsourced_queues.count, worker.outsourced_jobs.count]
    end

    print_table table
  end
end