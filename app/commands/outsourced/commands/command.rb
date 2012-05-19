class Outsourced::Commands::Command < Clamp::Command
  class << self
    def requires_worker
      parameter "WORKER_NAME", "name of the worker"
    end

    def requires_queue
      parameter "QUEUE_NAME", "name of the queue"
    end
  end
  def say(message)
    puts message
  end

  def persist(object)
    if object.save
      say "Created #{object.name}"
    else
      say "Failed creating #{object.name}:"
      object.errors.full_messages.each do |message|
        say "  -  #{message}"
      end
    end
  end

  def update(object)
    if object.save
      say "Updated #{object.name}"
    else
      say "Failed creating #{object.name}:"
      object.errors.full_messages.each do |message|
        say "  -  #{message}"
      end
    end
  end

  def queues
    Outsourced::Queue.all
  end

  def workers
    Outsourced::Worker.all
  end

  def destroy(object)
    object.destroy
    say "Deleted #{object.name}"
  end

  def with_queue(queue_name)
    queue = Outsourced::Queue.find_by_name(queue_name)
    if queue
      yield queue
    else
      say "Couldn't find a queue named #{queue_name}"
    end
  end

  def with_worker(worker_name)
    worker = Outsourced::Worker.find_by_name(worker_name)
    if worker
      yield worker
    else
      say "Couldn't find a worker named #{worker_name}"
    end
  end
end