@event_modules = {}

def register_event_module(event, *catch)
	catch.each {|c| @event_modules[c] = event }
end

def is_event_module?(catch)
	@event_modules[catch.sub(/^\//,'')]
end

def run_event_modules(args)
	modules = @event_modules.find_all{|k,v| args[:event] == k}
	modules.each do |reg, event|
		send(event, args)
	end
end

register_event_module :e_privmsg, 'PRIVMSG'
def e_privmsg(args)
	if action = args[:args][/^\001(\S+)\s?(.*)\001/,1 ]
		case action
			when "ACTION": log_m args[:target].strip, "* #{args[:nick]} #{$2}", @channel_f
			when "TIME":   p 'here';log "NOTICE #{args[:nick]} :\001TIME #{Time.now}\001", @socket
		end
	else
		log_m args[:target].strip, "<#{args[:nick]}> #{args[:args]}", @channel_f
	end
end

register_event_module :e_join, 'JOIN'
def e_join(args)
	log_m args[:args].strip, "#{args[:nick]} [#{args[:mask]}] has joined #{args[:args]}", @channel_f
end

register_event_module :e_part, 'PART'
def e_part(args)
	log_m args[:target], "#{args[:nick]} [#{args[:mask]}] has left #{args[:target]}", @channel_f
end
