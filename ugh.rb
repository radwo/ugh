# encoding: utf-8

require "bundler/setup"
require "gaminator"

class UghGame

  def initialize(width, height)
    @points = 0
    @width  = width
    @height = height
    @tick   = 0
    @taxi   = Taxi.new(15, 15)
    @passengers = []
    create_new_passanger
    @destinations = [EndPoint.new(10,15), EndPoint.new(2,9), EndPoint.new(20,3)]
  end

  def exit_message
    'bye bye!'
  end

  def tick
    @tick += 1
    fall
    take_passanger
    create_new_passanger if @passengers.count == 0
    any_delivered?
  end

  def objects
    [@taxi] + @passengers + @destinations
  end

  def input_map
    {
      ?a => :move_left,
      ?w => :move_up,
      ?s => :move_down,
      ?d => :move_right
    }
  end

  def textbox_content
    objects.first.inspect + @passengers.inspect + "pass #{@taxi.passanger?.inspect}"
  end

  def wait?
    false
  end

  def sleep_time
    0.01
  end

  def move_left
    objects.first.x -= 1 if objects.first.x > 0
  end

  def move_right
    objects.first.x += 1 if objects.first.x < @width-1
  end

  def move_down
    objects.first.y += 1 if objects.first.y < @height-1
  end

  def move_up
    objects.first.y -= 1 if objects.first.y > 0
  end

  def any_delivered?
    @passengers.each do |p|
      if p.delivered?(@destinations.first)
        delivered(p)
      end
    end
  end

  def delivered(passanger)
    @points += 1
    @passengers.delete(passanger)
    @taxi.passanger = nil
  end

  def fall
    move_down if @tick % 50 == 0 && objects.first.y < @height-1
  end

  def create_new_passanger
    @passengers << Passenger.new(rand(@width),rand(@height))
  end

  def take_passanger
    @passengers.each { |p| @taxi.take!(p) if !@taxi.passanger? && p.touched?(@taxi) }
  end

  class Obj < Struct.new(:x, :y); end

  class EndPoint < Obj
    def char
      "E"
    end

    def color
      Curses::COLOR_GREEN
    end
  end


  class Passenger < Obj
    def char
      "X"
    end

    def touched?(taxi)
      [x, x+1, x-1].include?(taxi.x) && taxi.y == (y-1)
    end

    def delivered?(meta)
      meta.x == x && meta.y == y
    end
  end

  class Taxi < Obj
    def initialize(*args)
      super
      @passanger = nil
    end

    def x=(*args)
      super
      passanger.x = x if passanger?
    end

    def y=(*args)
      super
      passanger.y = y + 1 if passanger?
    end

    def char
      "O"
    end

    def take!(_passanger)
      self.passanger = _passanger
    end

    def passanger=(_passanger)
      @passanger = _passanger
    end

    def passanger
      @passanger ||= nil
    end

    def passanger?
      !@passanger.nil?
    end
  end

end

Gaminator::Runner.new(UghGame, :rows => 30, :cols => 50).run
