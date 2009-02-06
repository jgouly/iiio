require 'socket';require 'readline';require 'util';require 'event_modules';require 'command_modules'
@socket = TCPSocket.new ARGV[0], 6667
@server_f = open(ARGV[0], "a")
@channel_f = open("chan_log","a")
@channels, @channel_aliases, @bind_mode = [], {}
["NICK #{@nick = ARGV[1]}", "USER #{ARGV[1]} 0 * :iiio user"].each { |msg| log msg, @socket }

while input = select([@socket, $stdin],nil, nil)
	load 'util.rb'
	load 'command_modules.rb'
	load 'event_modules.rb'
	input[0].each do |i|
		if i == @socket
			handle_event @socket.gets.chomp
		else
			if @bind_mode
				print "[#{@bind_mode}] "
			end
			handle_command STDIN.gets
		end
	end
	@server_f.flush
	@channel_f.flush
end
@server_f.close
@channel_f.close
