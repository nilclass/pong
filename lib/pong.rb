
class Pong

  class Actions
    def initialize(pong)
      @pong = pong
    end

    def move_panel(side, direction)
      offset = direction == 'up' ? -0.1 : 0.1
      @pong.panel_positions[side] += offset
      @pong.update_ui_state!
    end
  end

  attr :actions
  attr :panel_positions

  def initialize
    @actions = Actions.new(self)
    @panel_positions = [0.0, 0.0]
    @clients = []
  end

  def add_client(client)
    @clients.push(client)
    update_ui_state!
  end

  def remove_client(client)
    @clients.delete(client)
  end

  def update_ui_state!
    @panel_positions.map! do |pos|
      pos > 1.0 ? 1.0 : (pos < 0.0 ? 0.0 : pos)
    end
    @clients.each_with_index do |client, i|
      client.send_command('update', {
          side: i,
          panel_positions: @panel_positions
        })
    end
  end
end
