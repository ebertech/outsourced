class Outsourced::Commands::Queue::List < Outsourced::Commands::Queue::Command
  def execute
    queues.each do |queue|
      say queue.name
    end
  end
end