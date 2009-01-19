def log(input,  out)
  out.puts input
end

def log_m(msg, out)
 log "#{Time.now.strftime("%d/%m/%y %H:%M:%S")} #{msg}", out
end
