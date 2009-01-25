require 'socket';require 'util';require 'module'
@socket = TCPSocket.new ARGV[0], 6667
@server_f = open ARGV[0], "a"
@channels, @channel_aliases, @bind_mode = [], {}
["NICK #{@nick = ARGV[1]}", "USER #{ARGV[1]} 0 * :iiio user"].each { |msg| log msg, @socket }

while input = select([@socket, STDIN], nil, nil)
	load 'util.rb'
	load 'module.rb'
	input[0].each do |i|
		if i == @socket
			handle_output @socket.gets
		else
			if @bind_mode
				print "[#{@bind_mode}] "
			end
			handle_input STDIN.gets
		end
	end
	@server_f.flush
end
@server_f.close
