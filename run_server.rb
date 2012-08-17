#!/usr/bin/ruby
'''
Start server 
'''
require './msg_pipe.rb'
require './handler.rb'
require './tools.rb'
include Tools


MsgPipe.server(get_config['server']['rpc_host'], Handler.new) do |server|
  puts 'server starting to accept work'
  server.work!
end
