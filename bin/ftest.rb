#!/usr/bin/env ruby
require File.expand_path File.join(File.dirname(__FILE__), %w{.. lib foiled})
include GuiGeo

Foiled::XtermScreen.new.start(false) do |screen|
  screen.event_manager.instance_eval do
    last_event = nil
    add_handler :tick do
      screen.output.instance_eval do
        without_cursor do
          out_at point(0,0), Time.now
          out_at point(0,1), "size: #{screen.state.size.inspect}"

          if last_event
            e = last_event.inspect
            e += "\nfailure_info (raw=#{last_event[:raw].inspect}): #{last_event[:failure_info]}" if last_event[:failure_info]
            e += "\ntrace:\n  "+last_event[:exception].backtrace.join("\n  ") if last_event[:type]==:event_exception
            cursor(0,2)
            puts "last_event: #{e}   "
          end
        end
      end
    end
    add_handler :all do |event|
      Foiled::XtermLog.log "last_event = #{event.inspect}"
      last_event = event
    end
  end
end
