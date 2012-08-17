require './msg_pipe.rb'
require 'tools.rb'
# call some functions on the server
# see handler.rb

MsgPipe.client("tcp://localhost:#{config['server']['port']}") do |client|
  p client.call(:add, 1, 2)

  p client.call(:hi)

  begin
    client.call(:throw)
  rescue MsgPipe::RemoteError => e
    p e
  end
  

  p client.call(:echo, 'willenlos')

  begin
    client.call(:private_method)
  rescue MsgPipe::RemoteError => e
    p e
  end

  puts "everthing as expected"
end
