class Outsourced::Commands::Command < Clamp::Command
  class << self
    def requires_worker
      parameter "WORKER_NAME", "name of the worker"
    end

    def requires_queue
      parameter "QUEUE_NAME", "name of the queue"
    end
  end

  delegate :mute, :say, :say_status, :ask, :yes?, :no?, :print_table, :print_wrapped,
           :error, :set_color, :file_collision, :to => :shell


  def shell
    @shell ||= Thor::Base.shell.new
  end

  def persist(object)
    if object.save
      say_status object.class.table_name.singularize, "Created #{object.name}"
    else
      say_status object.class.table_name.singularize, "Failed creating #{object.name}:", :red
      object.errors.full_messages.each do |message|
        say "  -  #{message}"
      end
    end
  end

  def update(object)
    if object.save
      say_status object.class.table_name.singularize, "Updated #{object.name}"
    else
      say_status object.class.table_name.singularize,  "Failed creating #{object.name}:", :red
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
    say_status :deleted, object.name
  end

  def with_queue(queue_name)
    queue = Outsourced::Queue.find_by_name(queue_name)
    if queue
      yield queue
    else
      say_status :outsourced_queue, "Couldn't find a queue named #{queue_name}", :red
    end
  end

  def with_worker(worker_name)
    worker = Outsourced::Worker.find_by_name(worker_name)
    if worker
      yield worker
    else
      say_status :outsourced_worker, "Couldn't find a worker named #{worker_name}", :red
    end
  end

end