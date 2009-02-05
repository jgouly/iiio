@input_modules = {}

def register_input_module(event, *catch)
	catch.each {|c| @input_modules[c] = event }
end

def is_input_module?(catch)
	@input_modules[catch.sub(/^\//,'')]
end

def run_input_modules(cmd, args)
	prefix, command = cmd[/^(\/)?(.+)/,1], $2
	if @bind_mode and !prefix
		handle_privmsg(@bind_mode,[cmd, *args])
	else
		modules = @input_modules.find_all{|k,v| command == k}
		modules.each do |reg, event|
			send(event, *args)
		end
	end
end

register_input_module :handle_raw, 'raw'
def handle_raw(*args)
	log args.join(' '), @socket
end

register_input_module :handle_privmsg, 'privmsg', '>'
def handle_privmsg(target, *args)
 log "PRIVMSG #{target = channel_name target} :#{args.join ' '}", @socket
 log_m target, "<#{@nick}> #{args.join ' '}", @server_f
end

register_input_module :handle_join, 'j', 'join'
def handle_join(channel, *args)
	@channels.push channel
	log "JOIN #{channel_name channel}", @socket
end

register_input_module :handle_part, 'p', 'part'
def handle_part(channel, *args)
	@channels.delete channel
	@channel_aliases.delete_if{|k,v| v == channel}
	log "PART #{channel_name channel}", @socket
end

register_input_module :handle_action, 'me'
def handle_action(target, *args)
	if @bind_mode
		args.unshift target
		target = @bind_mode
	end
	log "PRIVMSG #{channel_name target} :\001ACTION #{args.join ' '}\001", @socket
end

register_input_module :handle_alias, 'alias'
def handle_alias(new_name, old_name, *args)
	@channel_aliases[new_name] = channel_name old_name
end

register_input_module :handle_bind, 'bind', '&', 'unbind'
def handle_bind(*args)
	@bind_mode = channel_name args[0]
end

register_input_module :handle_nicklist, 'nicklist', 'names'
def handle_nicklist(*args)
	log "NAMES #{channel_name args[0] ? args[0] : @bind_mode}", @socket
end
