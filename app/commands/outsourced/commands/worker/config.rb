class Outsourced::Commands::Worker::Config < Outsourced::Commands::Worker::Command
  requires_worker

  option ["-o", "--output-file"], "OUTPUT_FILE", "The file to write to", :attribute_name => :output_file

  def execute
    with_worker(worker_name) do |worker|
      unless output_file.blank?
        file = File.expand_path(output_file.to_s)
        File.open(file, "wb") do |f|
          f.write(worker.to_yaml)
          say_status :outsourced_worker, "Saved configuration to: #{file}"
        end
      else
        puts worker.to_yaml
      end
    end
  end
end