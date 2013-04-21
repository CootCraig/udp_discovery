require 'rubygems'
require 'bundler/setup'

require 'json'
require 'celluloid/autostart'
require 'celluloid/io'

class Broadcaster
  include Celluloid::IO
  def initialize
    @remote_host = nil
    @send_port = 38018
    @listen_port = 38019
    @broadcast_message = { :port => @listen_port }.to_json

    @listen_socket = UDPSocket.new
    @listen_socket.bind '0.0.0.0',@listen_port
    async.listen

    @broadcast_socket = ::UDPSocket.new
    @broadcast_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)

    @timer = after(1) {  async.broadcast }
  end
  def listen
    loop do
      rcv,addr = @listen_socket.recvfrom 512
      @remote_hostname = (JSON.parse(rcv))['hostname']
      @remote_host = addr[2]
      puts "remote_hostname #{@remote_hostname} remote_host #{@remote_host}"
    end
  end
  def broadcast
    puts "broadcast"
    @broadcast_socket.send(@broadcast_message, 0, '<broadcast>', @send_port)
    @timer = after(3) {  async.broadcast }
  end

end
b = Broadcaster.new
sleep

if false
  msg = { :port => 38019 }
  addr = ['<broadcast>', 38018]
  sock = UDPSocket.new
  sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
  puts "sending"
  count = sock.send(msg.to_json, 0, addr[0], addr[1])
  puts "#{count} sent"
end

