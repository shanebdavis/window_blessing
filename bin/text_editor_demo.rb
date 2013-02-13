#!/usr/bin/env ruby
# encoding: UTF-8
require File.expand_path File.join(File.dirname(__FILE__), %w{.. lib foiled})
include GuiGeo
include Foiled::Tools
include Foiled
include Widgets

class Theme
  include Foiled::Tools
  COLORS = {
    background: color("ffc").to_screen_color,
    foreground: color(0.25).to_screen_color,
    comment: color(0.5).to_screen_color,
    keyword: color("4a744a").to_screen_color,
    string: color("4a7494").to_screen_color,
    number: color("4a7494").to_screen_color,
    regexp: color("4a7494").to_screen_color,
    constant: color("c96600").to_screen_color,
    operator: color("4a744a").to_screen_color
  }
end

class CodeMarkup < BabelBridge::Parser

  rule :file, :space, many?(:element) do
    def colors
      [[Theme::COLORS[:foreground]]*space.match_length,element.collect{|a| a.colors}].flatten
    end
  end

  rule :element, :comment, :space do
    def colors; [Theme::COLORS[:comment]] * match_length; end
  end

  rule :element, :keyword, :space do
    def colors; [Theme::COLORS[:keyword]] * match_length; end
  end

  rule :element, :string, :space do
    def colors; [Theme::COLORS[:string]] * match_length; end
  end

  rule :element, :regexp, :space do
    def colors; [Theme::COLORS[:regex]] * match_length; end
  end

  rule :element, :constant, :space do
    def colors; [Theme::COLORS[:constant]] * match_length; end
  end

  rule :element, :operator, :space do
    def colors; [Theme::COLORS[:operator]] * match_length; end
  end

  rule :element, :number, :space do
    def colors; [Theme::COLORS[:number]] * match_length; end
  end

  rule :element, :identifier, :space do
    def colors; [Theme::COLORS[:foreground]] * match_length; end
  end

  rule :element, :non_space, :space do
    def colors; [Theme::COLORS[:foreground]] * match_length; end
  end

  rule :space, /\s*/
  rule :number, /[0-9]+(\.[0-9]+)?/
  rule :comment, /#([^\n]|$)*/
  rule :string, /"(\\.|[^\\"])*"/
  rule :string, /:[_a-zA-Z0-9]+[?!]?/
  rule :regexp, /\/(\\.|[^\\\/])*\//
  rule :operator, /[-!@$%^&*()_+={}|\[\];:<>\?,\.\/~]+/
  rule :keyword, /class|end|def|and|or|do|if|then/
  rule :keyword, /else|elsif|case|then|when|require|include/
  rule :identifier, /[_a-zA-Z][0-9_a-zA-Z]*/
  rule :constant, /[A-Z][0-9_a-zA-Z]*/
  rule :non_space, /[^\s]/
end

class TextEditor < Window
  attr_accessor_with_redraw :edit_buffer, :cursor_loc, :cursor_bg

  def initialize(filename)
    super rect(0,0,80,20)
    self.bg = Theme::COLORS[:background]
    self.fg = Theme::COLORS[:foreground]
    @cursor_loc = point
    @cursor_bg = Color.yellow

    init_event_handlers
    self.text = File.read(filename)

    on :parent_resize do |event|
      self.size = event[:size]
    end
    on :parent_set do |event|
      self.size = parent.size
    end
  end

  def init_event_handlers
    on :string_input do |event|
      string = event[:string]
      line = current_line
      x,y = cursor_loc.x,cursor_loc.y
      if x > line.length
        line += " "*(x - line.length)
      end
      new_line = if x == 0
        string + line
      elsif x == line.length
        line + string
      else
        line[0..x-1] + string + line[x..-1]
      end
      new_lines = new_line.split "\n"

      #cop-out for now
      edit_buffer[cursor_loc.y]= new_lines[0]
      request_redraw_internal(rect(cursor_loc,point(size.x,1)))
      cursor_loc.x += string.length
      color_lines[y]=nil
    end

    on :key_press do |event|
      c = cursor_loc.clone
      case event[:key]
      when :control_m then c = newline_at_cursor
      when :backspace then c = backspace
      when :home      then c = point(0,c.y)
      when :page_up   then #c = point(0,c.y)
      when :page_down then #c = point(0,c.y)
      when :end       then c = point(edit_buffer[c.y].length,c.y)
      when :left      then
        if c.x == 0
          if c.y > 0
            c.y-=1
            c.x = edit_buffer[c.y].length
          end
        else
          c.x -= 1
        end
      when :right     then c.x += 1
      when :up        then c.y = max(0, c.y-1)
      when :down      then c.y = min(c.y+1, edit_buffer.length-1)
      end
      self.cursor_loc = c
    end

    on :focus do
      request_redraw_internal
    end

    on :blur do
      request_redraw_internal
    end
  end

  def cursor_area
    rect(cursor_loc - scroll_pos,point(1,1))
  end

  def cursor_loc=(c)
    request_redraw_internal cursor_area
    @cursor_loc = c
    request_redraw_internal cursor_area
  end

  def newline_at_cursor
    c = cursor_loc.clone
    x,y = c.x, c.y
    if x == 0
      edit_buffer.insert(y,"")
      color_lines.insert(y,nil)
    elsif x >= current_line.length
      edit_buffer.insert(y+1,"")
      color_lines.insert(y+1,nil)
    else
      l = current_line
      edit_buffer.insert(y,l[0..x-1])
      color_lines.insert(y,nil)
      edit_buffer[y+1] = l[x..-1]
    end
    color_lines[y]=color_lines[y+1]=nil
    request_redraw_internal
    point(0,y+1)
  end

  def backspace
    c = cursor_loc.clone
    x,y = c.x, c.y
    if x == 0
      if y > 0
        c.x = edit_buffer[y-1].length
        edit_buffer[y-1] += edit_buffer[y]
        color_lines[y-1] = nil
        c.y -= 1

        edit_buffer.delete_at(y)
        color_lines.delete_at(y)

        request_redraw_internal
      end
    else
      edit_buffer[y] = if x == 1
        current_line[1..-1]
      elsif x == current_line.length
        current_line[0..-2]
      else
        current_line[0..x-2] + current_line[x..-1]
      end
      c.x -= 1
      request_redraw_current_line
    end
    color_lines[y]=nil
    c
  end

  def request_redraw_current_line
    request_redraw_internal current_line_area
  end

  def line_area(line_number)
    rect(point(0,line_number),point(edit_buffer[line_number].length,1))
  end

  def current_line_area
    line_area(cursor_loc.y)
  end

  def current_line
    edit_buffer[cursor_loc.y]
  end

  def text
    edit_buffer.join("\n")
  end

  def text=(t)
    self.edit_buffer = t.split("\n")
  end

  def scroll_pos
    point
  end

  def line_range
    scroll_pos.y..scroll_pos.y+size.y-1
  end

  def visible_lines
    edit_buffer[line_range]
  end

  def color_lines
    @color_lines ||= []
  end

  def draw_background
    syntax_highlighter = CodeMarkup.new
    crop_area = buffer.crop_area

    range = (crop_area+scroll_pos).y_range
    lines = edit_buffer[range]
    clines = color_lines[range]

    lines.each_with_index do |a,i|
      clines[i] ||= begin
        p = syntax_highlighter.parse(a.clone)
        log syntax_highlighter.parser_failure_info unless p
        p.colors
      end
      buffer.contents[i+crop_area.y] = a
      buffer.fg_buffer[i+crop_area.y] = clines[i]
    end

    color_lines[range] = clines

    buffer.sanitize_contents crop_area.y_range
    buffer.normalize crop_area.y_range
    buffer.fill bg:bg
    buffer.fill :area => cursor_area, :bg => cursor_bg if focused?
  end
end

WindowedScreen.new.start(:full=>true, :utf8 => true) do |screen|
  filename = __FILE__
  screen.root_window.add_child te=TextEditor.new(filename)
  te.focus
end
