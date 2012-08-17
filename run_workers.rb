require './msg_pipe.rb'
require '../life_service_ruby/life_hander.rb'
require '../life_lib_ruby/tools.rb'
include Tools

#Start process server number in ARGV!
if ARGV.length != 1
  puts "Usage: bundle exec ruby zworker.rb <number_of_processes>"
  exit 1
end

num_workers = ARGV[0].to_i

num_workers.times do 
  fork do
    MsgPipe.worker(get_config("./config.yaml")["server"]["rpc_host"], LifeHander.new) do |worker|
      puts "Worker: #{Process.pid} started ..."
      worker.work! # never returns
    end

    exit 0
  end
end

Process.waitall
