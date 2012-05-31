
class Pong

  class Actions
    def initialize(pong)
      @pong = pong
    end

    def move_panel(params)
      offset = params['direction'] == 'up' ? -0.1 : 0.1
      @pong.panel_positions[params['side']] += offset
      @pong.update_ui_state!
    end

    def start_game
      @pong.start!
    end

    def stop_game
      @pong.stop!
    end
  end

  HEIGHT = 300
  WIDTH = 500

  MIN_BALL_X = 25
  MIN_BALL_Y = 5
  MAX_BALL_X = WIDTH - 25
  MAX_BALL_Y = HEIGHT - 5
  PANEL_WIDTH = 50

  attr :actions
  attr :panel_positions

  def initialize
    @actions = Actions.new(self)
    @clients = []
    reset!
  end

  def running?
    ! @timer.nil?
  end

  def start!
    reset!
    @timer = EM.add_periodic_timer(0.1) do
      move_ball
    end
  end

  def stop!
    return unless running?
    @timer.cancel
    @timer = nil
  end

  def move_ball
    @ball_position = add_vector(@ball_position, @ball_vector)

    if @ball_position[0] <= MIN_BALL_X
      if panel_at?(0, @ball_position[1])
        @ball_vector[0] *= -1
      else
        # hack to loose once the ball hits the wall :)
        EM.add_timer(0.3) { loose!(0) }
      end
    elsif @ball_position[0] >= MAX_BALL_X
      if panel_at?(1, @ball_position[1])
        @ball_vector[0] *= -1
      else
        EM.add_timer(0.3) { loose!(1) }
      end
    elsif @ball_position[1] <= MIN_BALL_Y || @ball_position[1] >= MAX_BALL_Y
      @ball_vector[1] *= -1
    end

    update_ui_state!
  end

  def loose!(side)
    stop!
    send_to_each('loose', side)
  end

  def panel_at?(panel, position_y)
    absolute_panel_pos = @panel_positions[panel] * (HEIGHT - PANEL_WIDTH)
    panel_start = absolute_panel_pos
    panel_end = absolute_panel_pos + PANEL_WIDTH
    p ['PANEL', panel_start, panel_end, 'POS', position_y]
    return  (panel_start..panel_end).include?(position_y.to_f)
  end

  def add_vector(a, b)
    [ a[0] + b[0],
      a[1] + b[1] ]
  end

  def reset!
    @panel_positions = [0.5, 0.5]
    @ball_position = [250, 150]
    @ball_vector = [10, 10]
  end

  def add_client(client)
    @clients.push(client)
    update_ui_state!
  end

  def remove_client(client)
    @clients.delete(client)
    stop!
  end

  def update_ui_state!
    @panel_positions.map! do |pos|
      pos > 1.0 ? 1.0 : (pos < 0.0 ? 0.0 : pos)
    end
    @clients.each_with_index do |client, i|
      client.send_command('update', {
          side: i,
          panel_positions: @panel_positions,
          ball_position: @ball_position
        })
    end
  end

  def send_to_each(*args)
    @clients.each do |client|
      client.send_command(*args)
    end
  end

end
