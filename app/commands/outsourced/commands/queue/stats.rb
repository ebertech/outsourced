class Outsourced::Commands::Queue::Stats < Outsourced::Commands::Queue::Command

  parameter "[QUEUE_NAME]", "name of the queue"

  def execute
    if queue_name
      with_queue(queue_name) do |queue|
        print_statistics("#{queue.name} statistics", ::Outsourced::Queue.where(:id => queue.id))
      end
    else
      print_statistics("Overall statistics", ::Outsourced::Queue)
    end
  end

  private

  def print_statistics(title, queues)
    say title
    print_summary(queues)
    say ""
    print_state_statistics(queues)
  end

  def print_summary(queues)
    table = []
    say "Summary"
    table << ["Name", "Capacity", "Number of Jobs", "Number of Workers"]
    queues.all.each do |queue|
      table << [queue.name, queue.capacity, queue.outsourced_jobs.count, queue.outsourced_workers.count]
    end
    print_table table
  end

  def print_state_statistics(queues)
    table = []
    jobs = Outsourced::Job.for_queues(queues.all)
    say "By state statistics"
    table << ["State", "Number of Jobs"]
    Outsourced::Job.state_machine.states.map(&:name).map(&:to_s).sort.each do |state|
      table << [state, Outsourced::Job.for_queues(queues.all).where(:state => state).count]
    end
    print_table table
  end
end