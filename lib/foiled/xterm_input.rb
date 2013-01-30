
module Foiled
class XtermInput
  attr_reader :events, :event_parser

  def XtermInput.input_commands
    {"t" => :screen_size}
  end

  def puts(s)
    $stdout.puts s+"\r"
  end

  def initialize
    @event_parser = EventParser.new
    @events = []
  end

  def read_pending_input
    #@input_log ||= []
    read = nil
    begin
      while c = STDIN.read_nonblock(1000)
        if read
          read += c
        else
          read = c
        end
      end
    rescue Errno::EINTR
      #@input_log << "Errno::EINTR"
    rescue Errno::EAGAIN  # nothing was ready to be read
      #@input_log << "Errno::EAGAIN"
    rescue EOFError
      #@input_log << "EOFError"
    end
    read
  end

  # return number of new events
  def process_pending
    if raw = read_pending_input
      parsed = event_parser.parse(raw)
      if parsed
        new_events = parsed.events
        @events += new_events
        new_events.length
      else
        @events << {:type => :event_parser_failure, :failure_info => event_parser.parser_failure_info}
        1
      end
    else
      0
    end
  end

  def each_event
    process_pending
    events.each_with_index do |event|
      yield event
    end
  end

  def reset_events
    @events = []
  end
end
end
