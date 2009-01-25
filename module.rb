@modules = {}

def register_module(event, *catch)
	catch.each {|c| @modules[c] = event }
end

def run_modules(cmd, args)
	prefix, command = cmd[/^(\/)?(.+)/,1], $2
	if @bind_mode and !prefix
		handle_privmsg(@bind_mode,[cmd, *args])
	else
		modules = @modules.find_all{|k,v| command == k}
		modules.each do |reg, event|
			send(event, *args)
		end
	end
end

register_module :handle_privmsg, 'privmsg', '>'
def handle_privmsg(target, *args)
 log "PRIVMSG #{target = channel_name target} :#{args.join ' '}", @socket;
end

register_module :handle_join, 'j', 'join'
def handle_join(channel, *args)
	@channels.push channel
	log "JOIN #{channel_name channel}", @socket
end

register_module :handle_part, 'p', 'part'
def handle_part(channel, *args)
	@channels.delete channel
	@channel_aliases.delete_if{|k,v| v == channel}
	log "PART #{channel_name channel}", @socket
end

register_module :handle_action, 'me'
def handle_action(target, *args)
	if @bind_mode
		args.unshift target
		target = @bind_mode
	end
	log "PRIVMSG #{channel_name target} :\001ACTION #{args.join ' '}\001", @socket
end

register_module :handle_alias, 'alias'
def handle_alias(new_name, old_name, *args)
	@channel_aliases[new_name] = channel_name old_name
end

register_module :handle_bind, 'bind', '&'
def handle_bind(*args)
	@bind_mode = channel_name args[0]
end
