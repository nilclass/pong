
require 'rubygems'
require 'bundler'

Bundler.require

require './lib/pong.rb'
require './lib/socket_app.rb'
require './lib/static_app.rb'

## Stupid websocket-rack bug:
class Rack::WebSocket::WebSocketError < Exception
end

EM.run {

  pong = Pong.new

  app = Rack::Builder.new do

    map '/socket' do
      run SocketApp.new(pong)
    end

    map '/' do
      run StaticApp
    end

  end.to_app

  thin = Thin::Server.new('0.0.0.0', 1234, app)
  thin.start
}

