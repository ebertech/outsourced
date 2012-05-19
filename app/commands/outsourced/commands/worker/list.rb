class Outsourced::Commands::Worker::List < Outsourced::Commands::Worker::Command
  def execute
    workers.each do |worker|
      say worker.name
    end
  end
end