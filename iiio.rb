require 'socket';require 'util'
@socket = TCPSocket.new ARGV[0], 6667
@server_f = open ARGV[0], "a"
["NICK #{ARGV[1]}", "USER #{ARGV[1]} 0 * :iiio user", "JOIN #{ARGV[2]}"].each { |msg| log msg, @socket }

while input = select([@socket, STDIN], nil, nil)
  input[0].each do |i|
    if i == @socket
      log line = @socket.gets, @server_f
      case line
        when /^PING :(.+)$/i: @socket.puts "PONG :#{$1}"
        when /:([^!]*)![^ ].* +PRIVMSG ([^ :]+) +:(.*)/:
	  m, nick, target, msg = *line.match(/:([^!]*)![^ ].* +PRIVMSG ([^ :]+) +:(.*)/)
	  if m
	    if action = msg[/^\001ACTION(.+)\001/, 1]
	      log_m "#{target} * #{nick}#{action}", @server_f
	    else
	      log_m "#{target} <#{nick}> #{msg}", @server_f
  	    end 
	  else
	    log line, @server_f
	  end
      end
    else
      log STDIN.gets, @socket
    end
  end
@server_f.flush
end
@server_f.close
