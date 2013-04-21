require 'rubygems'
require 'bundler/setup'

require 'json'
require 'celluloid/autostart'
require 'celluloid/io'

class Listener
  include Celluloid::IO

  def initialize
    @hostname = (`hostname`).strip
    @response_message = {:hostname => @hostname}.to_json
    @listen_port = 38018
    @listen_socket = UDPSocket.new
    @listen_socket.bind '0.0.0.0',@listen_port
    @respond_socket = UDPSocket.new
    async.listen
  end
  def listen
    loop do
      rcv,addr = @listen_socket.recvfrom 512
      rcv_hash = JSON.parse rcv
      respond_host = addr[2]
      respond_port = rcv_hash['port']
      puts "rcv [#{rcv}] addr #{addr} respond_host #{respond_host} respond_port #{respond_port}"
      async.respond respond_host,respond_port
    end
  end
  def respond host,port
    @respond_socket.send @response_message,0, host,port
  end
end

server = Listener.new
puts "Server started"
sleep

# rcv [["Are you there?", ["AF_INET", 50627, "127.0.0.1", "127.0.0.1"]]]

