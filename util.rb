def log(input, out)
	out.puts input
end

def log_m(target, msg, out)
	log "#{target} #{Time.now.strftime("%d/%m/%y %H:%M:%S")} #{msg}", out
end

def handle_input(input)
	case input
		when /(\S+)(.*)/: run_modules $1, $2.split(/\s/) 
	else
		log input, @socket
	end
end

def handle_output(output)
	case output
		when /^PING :(.+)$/i: @socket.puts "PONG :#{$1}"
		when /:([^!]*)![^ ].* +PRIVMSG ([^ :]+) +:(.*)/:
			nick, target, msg = $1, $2, $3
			if action = msg[/^\001ACTION(.+)\001/, 1]
				log output, @server_f
				log_m target, "* #{nick}#{action}", @server_f
			else
				log_m target, "<#{nick}> #{msg}", @server_f
			end
		else log output, @server_f
	end
end

def channel_name(name)
  case name 
		when /^#/: name
		when /^(\d+)$/: @channels[$1.to_i]
		when '': nil
		else @channel_aliases[name] || "##{name}"
	end
end

def _r(regex)
	/^#{@bind_mode ? "/" : "[\/]?" }#{regex}$/i 
end
