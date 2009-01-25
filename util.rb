def log(input, out)
	out.puts input
end

def log_m(target, msg, out)
	log "#{target} #{Time.now.strftime("%d/%m/%y %H:%M:%S")} #{msg}", out
end

def handle_input(input)
	case input
		when _r(/(privmsg|>) ([^\s]+) (.+)/): log "PRIVMSG #{target = channel_name $2} :#{$3}", @socket; log_m target, "<#{@nick}> #{$3}", @server_f 
		when _r(/me (.+) (.*)/): log "PRIVMSG #{channel_name $1} :\001ACTION #{$2}\001", @socket
		when _r(/(j|p) (.+)/):   log "#{join_part $1, channel_name($2)} #{channel_name $2}", @socket
		when _r(/chans/): log @channels.values.join(", "), @server_f
		when _r(/alias ([^\s]+) ([^\s]+)/): @channel_aliases[$1] = channel_name $2
		when _r(/&(.*)/): @bind_mode = channel_name $1.strip
	else
		if @bind_mode
			log "PRIVMSG #{@bind_mode} :#{input}", @socket
		else
			log input, @socket
		end
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

def join_part(join_part, channel)
	if join_part == 'j'
		@channels.push channel
		'JOIN'	
	else
		@channels.delete channel
		'PART'
	end
end

def _r(regex)
	/^#{@bind_mode ? "/" : "[\/]?" }#{regex}/i 
end
