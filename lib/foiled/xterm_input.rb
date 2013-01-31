
module Foiled
class XtermInput
  attr_reader :event_parser

  def initialize
    @event_parser = EventParser.new
  end

  def read_events
    events = []
    if raw = read_pending_input
      parsed = event_parser.parse(raw)
      if parsed
        new_events = parsed.events
        events += new_events
        new_events.length
      else
        events << {:type => :event_parser_failure, :failure_info => event_parser.parser_failure_info}
      end
    end
    events
  end

  private
  def read_pending_input
    read = nil
    begin
      while c = STDIN.read_nonblock(1000)
        read = read ? read + c : c
      end
    rescue Errno::EAGAIN  # nothing was ready to be read
    rescue Errno::EINTR
    rescue EOFError
    end
    read
  end

end
end
