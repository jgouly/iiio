def log(input, out)
	out.puts input
end

def log_m(target, msg, out)
	log "#{target} #{Time.now.strftime("%d/%m/%y %H:%M:%S")} #{msg}", out
end

def handle_command(input)
	if input =~ /^(\S+)\s(.*)/ and is_command_module? $1
		run_command_modules $1, $2.split(/\s/)
	else
		if @bind_mode
			handle_privmsg @bind_mode, input	
		else
			puts "err, right"
		end
	end
end

def handle_event(output)
	case output
		when /^PING :(.+)$/i: @socket.puts "PONG :#{$1}"
		when /^:(.*?)!(.*?)@(.*?) (.*?) (.*?)(?::(.*))?$/ : run_event_modules(:nick => $1, :mask => "#{$2}@#{$3}", :event => $4, :target => $5, :args => $6)
		else log output, @server_f
	end
end

def channel_name(name)
  case name 
		when /^#/: name
		when /^(\d+)$/: @channels[$1.to_i]
		when '', nil: nil
		else @channel_aliases[name] || "##{name}"
	end
end
