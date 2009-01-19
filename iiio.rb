require 'socket'
@socket = TCPSocket.new ARGV[0], 6667
["NICK #{ARGV[1]}", "USER #{ARGV[1]} 0 * :iiio user", "JOIN #{ARGV[2]}"].each { |msg| @socket.puts msg }
server_f = File.open ARGV[0], "a"
while input = select([@socket, STDIN], nil, nil)
input[0].each do |i|
if i == @socket
  server_f.puts line=@socket.gets
  server_f.flush
  if line =~ /^PING :(.+)$/i
    @socket.puts "PONG :"+$1
  end
else
  @socket.puts STDIN.gets
end;end;end
server_f.close
