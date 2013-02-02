#!/usr/bin/env ruby
require File.expand_path File.join(File.dirname(__FILE__), %w{.. lib foiled})
include GuiGeo

Foiled::WindowUI.new.start(true) do |win|
  r = rect 10, 10, 6, 3

  win.screen_buffer.draw_rect r, "%"

  win.event_manager.add_handler :key_press do |event|
    old_r = r | r
    Foiled::XtermLog.log "key_press: #{event[:key]}"
    case event[:key]
    when :home then r.loc.x = 0
    when :page_up then r.loc.y = 0
    when :left then r.loc.x -= 1
    when :right then r.loc.x += 1
    when :up then r.loc.y -= 1
    when :down then r.loc.y += 1
    end
    Foiled::XtermLog.log "r = #{r} old_r = #{old_r}"
    if r != old_r
      win.screen_buffer.draw_rect old_r, " "
      win.screen_buffer.draw_rect r, "%"
      win.dirty(old_r & r)
    end
  end
end
