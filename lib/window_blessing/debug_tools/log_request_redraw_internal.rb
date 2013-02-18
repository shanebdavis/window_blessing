module WindowBlessing
module DebugTools
module LogRequestRedrawInternal

  # sometimes you want to know where redraw requests are coming from
  # Since request_redraw_internal is recursive, you don't want to log the stack trace with every call - just the first one
  # This will log a stack-trace once per call
  def log_request_redraw_internal
    trace = Kernel.caller
    return if trace.count {|line| line["request_redraw_internal"]} > 1
    log "request_redraw_internal trace @requested_redraw_area=#{@requested_redraw_area} path:#{path}\n  "+ trace.join("\n  ")
  end

end
end
end
