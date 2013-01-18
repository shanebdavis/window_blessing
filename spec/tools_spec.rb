require 'spec_helper'

module Foiled
describe "Tools" do
  include Tools

  it "overlapping_span with strings" do
    overlapping_span(13, "abcd", 12).should == [12,""]
    overlapping_span(13, "a", 12).should == [12,""]
    overlapping_span(13, "", 12).should == [12,""]
    overlapping_span(10, "abcd", 12).should == [10,"ab"]
    overlapping_span(10, "abcd", 14).should == [10,"abcd"]
    overlapping_span(10, "abcd", 16).should == [10,"abcd"]
    overlapping_span(9, "abcd", 12).should == [9,"abc"]

    overlapping_span(0, "abcd", 12).should == [0,"abcd"]
    overlapping_span(-2, "abcd", 12).should == [0,"cd"]
  end

  it "overlapping_span with strings where length is less than span" do
    overlapping_span(-5, "abcd", 0).should == [0,""]
    overlapping_span(-1, "abcd", 0).should == [0,""]
    overlapping_span(0, "abcd", 0).should == [0,""]
    overlapping_span(1, "abcd", 0).should == [0,""]

    overlapping_span(-5, "abcd", 1).should == [1,""]
    overlapping_span(-1, "abcd", 1).should == [0,"b"]
    overlapping_span(0, "abcd", 1).should == [0,"a"]
    overlapping_span(1, "abcd", 1).should == [1,""]
  end

  it "overlapping_span with arrays" do
    overlapping_span(13, %w{a b c d}, 12).should == [12,[]]
    overlapping_span(13, [], 12).should == [12,[]]
    overlapping_span(12, %w{a b c d}, 12).should == [12,[]]
    overlapping_span(10, %w{a b c d}, 12).should == [10,%w{a b}]
    overlapping_span(9, %w{a b c d}, 12).should == [9,%w{a b c}]
    overlapping_span(0, %w{a b c d}, 12).should == [0,%w{a b c d}]
    overlapping_span(-2, %w{a b c d}, 12).should == [0,%w{c d}]
  end

  it "overlay_span" do
    overlay_span(-5, "abcd", "").should == ""
    overlay_span(-1, "abcd", "").should == ""
    overlay_span( 0, "abcd", "").should == ""
    overlay_span( 1, "abcd", "").should == ""

    overlay_span(-5, "abcd", "0").should == "0"
    overlay_span(-1, "abcd", "0").should == "b"
    overlay_span( 0, "abcd", "0").should == "a"
    overlay_span( 1, "abcd", "0").should == "0"

    overlay_span(-5, "abcd", "0123456789").should == "0123456789"
    overlay_span(-4, "abcd", "0123456789").should == "0123456789"
    overlay_span(-3, "abcd", "0123456789").should == "d123456789"
    overlay_span(-1, "abcd", "0123456789").should == "bcd3456789"
    overlay_span(0,  "abcd", "0123456789").should == "abcd456789"
    overlay_span(1,  "abcd", "0123456789").should == "0abcd56789"
    overlay_span(5,  "abcd", "0123456789").should == "01234abcd9"
    overlay_span(8,  "abcd", "0123456789").should == "01234567ab"
    overlay_span(9,  "abcd", "0123456789").should == "012345678a"
    overlay_span(10, "abcd", "0123456789").should == "0123456789"
    overlay_span(11, "abcd", "0123456789").should == "0123456789"

  end

  it "overlay_span with block" do
    overlay_span(2, [1, 2, 3, 4], 10.times.collect {|a|-a}) {|e| e+10}.should == [0, -1, 11, 12, 13, 14, -6, -7, -8, -9]
    overlay_span(2, [1, 2, 3, 4], 10.times.collect {|a|-a}) {|e,i| e+i}.should == [0, -1, -1, -1, -1, -1, -6, -7, -8, -9]
  end

  it "fill_line" do
    fill_line("a", 5).should == "aaaaa"
    fill_line("ab", 5).should == "ababa"
    fill_line("ab", 6).should == "ababab"
    fill_line("ab", 1).should == "a"
    fill_line("ab", 0).should == ""
  end
end
end
