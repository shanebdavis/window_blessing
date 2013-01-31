#!/usr/bin/env ruby
require File.expand_path File.join(File.dirname(__FILE__), %w{.. lib foiled})
include GuiGeo

Foiled::XtermScreen.new.start(false) do |screen|
  screen.event_manager.instance_eval do
    last_event = nil
    add_handler :tick do
      screen.output.instance_eval do
        out_at point(0,0), Time.now
        out_at point(0,1), "size: #{screen.state.size.inspect}"
        out_at point(0,2), last_event.inspect
      end
    end
    add_handler :all do |event|
      Foiled::XtermLog.log "last_event = #{event.inspect}"
      last_event = event
    end
  end
end
