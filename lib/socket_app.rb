
class SocketApp < Rack::WebSocket::Application

  attr :pong

  def initialize(pong)
    super()
    @pong = pong
  end

  def on_open(env)
    puts "Socket open."
    register_client(env)
  end

  def on_message(env, data)
    msg = JSON.load(data)
    puts "Message: #{msg.inspect}"
    pong.actions.__send__(msg['method'], *msg['args'])
  rescue => exc
    send_command('exception', exc.class, exc.message, exc.backtrace)
  end

  def on_close(env)
    puts "Socket closed."
    pong.remove_client(self)
  end

  def register_client(env)
    pong.add_client(self)
  end

  def send_command(method, *args)
    data = JSON.dump({
        method: method,
        args: args
      })
    send_data(data)
  end
end
