require 'socket'
@socket = TCPSocket.new ARGV[0], 6667
["NICK #{ARGV[1]}", "USER #{ARGV[1]} 0 * :iiio user", "JOIN #{ARGV[2]}"].each { |msg| @socket.puts msg }
@server_f = File.open ARGV[0], "a"

while input = select([@socket, STDIN], nil, nil)
  input[0].each do |i|
    if i == @socket
      line=@socket.gets
      case line
        when /^PING :(.+)$/i: @socket.puts "PONG :#{$1}"
        when /:([^!]*)![^ ].* +PRIVMSG ([^ :]+) +:(.*)/:
	  m, nick, target, msg = *line.match(/:([^!]*)![^ ].* +PRIVMSG ([^ :]+) +:(.*)/)
	  if m
	    if action = msg[/^\001ACTION(.+)\001/, 1]
	      @server_f.puts "#{Time.now.strftime("%d/%m/%y %H:%M:%S")} * #{nick}#{action}"
	    else
	      @server_f.puts "#{Time.now.strftime("%d/%m/%y %H:%M:%S")} #{target} <#{nick}> #{msg}"
  	    end 
	  else
	    @server_f.puts line
	  end
      end
    else
      @socket.puts STDIN.gets
    end
  end
@server_f.flush
end
server_f.close
