#!/usr/bin/env ruby
require File.expand_path File.join(File.dirname(__FILE__), %w{.. lib foiled})
include GuiGeo

Foiled::XtermScreen.new.start(:full=>true) do |screen|
  event_manager = screen.event_manager

  last_event = nil
  event_count = 0

  event_manager.add_handler :tick do
    screen.output.instance_eval do
      cursor(0,0)
      reset_color
      puts Time.now
      puts "Ctrl-Q to quit"
      puts "size: #{screen.state.size.inspect}"

      if last_event
        e = last_event.inspect
        e += "\nfailure_info (raw=#{last_event[:raw].inspect}): #{last_event[:failure_info]}" if last_event[:failure_info]
        e += "\ntrace:\n  "+last_event[:exception].backtrace.join("\n  ") if last_event[:type]==:event_exception
        puts "event #{event_count}: #{e}   "
      end
    end
  end

  event_manager.add_handler do |event|
    event_count += 1
    Foiled::XtermLog.log "last_event = #{event.inspect}"
    last_event = event
  end
end
