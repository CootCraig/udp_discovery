require 'rubygems'
require 'bundler/setup'

require 'json'
require 'celluloid/autostart'
require 'celluloid/io'

class Listener
  include Celluloid::IO

  def initialize
    @listen_port = 38018
    @socket = UDPSocket.new
    @socket.bind '0.0.0.0',@listen_port
    async.listen
  end
  def listen
    loop do
      rcv,addr = @socket.recvfrom 512
      rcv_hash = JSON.parse rcv
      respond_host = addr[2]
      respond_port = rcv_hash['port']
      puts "rcv [#{rcv}] addr #{addr} respond_host #{respond_host} respond_port #{respond_port}"
      async.respond respond_host,respond_port
    end
  end
  def respond host,port
    socket = UDPSocket.new
    socket.send 'Here I am',0, host,port
  end
end

server = Listener.new
puts "Server started"
sleep

# rcv [["Are you there?", ["AF_INET", 50627, "127.0.0.1", "127.0.0.1"]]]

