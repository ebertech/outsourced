module Outsourced
  class Command < Clamp::Command
    subcommand "worker", "manage workers" do
      subcommand "list", "list all workers", ::Outsourced::Commands::Worker::List
      subcommand "create", "create a new worker", ::Outsourced::Commands::Worker::Create
      subcommand "destroy", "delete a worker", ::Outsourced::Commands::Worker::Destroy
      subcommand "config", "show the configuration for a worker", ::Outsourced::Commands::Worker::Config
      subcommand "reset", "reset the authentication tokens for a worker", ::Outsourced::Commands::Worker::Reset
      subcommand "lock", "lock a worker from logging in", ::Outsourced::Commands::Worker::Lock
      subcommand "unlock", "unlock a locked-out worker", ::Outsourced::Commands::Worker::Unlock
      subcommand "stats", "show information about a worker", ::Outsourced::Commands::Worker::Stats
    end
    subcommand "queue", "manage queues" do
      subcommand "list", "list all queues", ::Outsourced::Commands::Queue::List
      subcommand "create", "create a new queue", ::Outsourced::Commands::Queue::Create
      subcommand "change", "change a queue", ::Outsourced::Commands::Queue::Change
      subcommand "empty", "remove all jobs from a queue", ::Outsourced::Commands::Queue::Empty
      subcommand "destroy", "delete a queue", ::Outsourced::Commands::Queue::Destroy
      subcommand "hire", "assign a worker to a queue", ::Outsourced::Commands::Queue::Hire
      subcommand "fire", "unassign a worker from a queue", ::Outsourced::Commands::Queue::Fire
      subcommand "stats", "show information about a queue", ::Outsourced::Commands::Queue::Stats
    end
  end
end