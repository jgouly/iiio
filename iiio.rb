require 'socket';require 'util'
@socket = TCPSocket.new ARGV[0], 6667
@server_f = open ARGV[0], "a"
@channels, @channel_aliases = [], {}
["NICK #{ARGV[1]}", "USER #{ARGV[1]} 0 * :iiio user"].each { |msg| log msg, @socket }

while input = select([@socket, STDIN], nil, nil)
	load 'util.rb'
	input[0].each do |i|
		if i == @socket
			handle_output @socket.gets.strip
		else
			handle_input STDIN.gets.strip
		end
	end
	@server_f.flush
end
@server_f.close
