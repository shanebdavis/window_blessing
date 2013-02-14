require 'spec_helper'

module WindowBlessing
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

  it "resize2d string" do
    r = resize2d([],point(2,3),"1")
    r.should == ["11", "11", "11"]

    r = resize2d(r,point(3,3),"2")
    r.should == ["112", "112", "112"]

    r = resize2d(r,point(3,2),"3")
    r.should == ["112", "112"]

    r = ["1","22","333"]
    r = resize2d(r,point(3,4),"-")
    r.should == ["1--", "22-", "333", "---"]
  end

  it "resize2d array" do
    r = resize2d([],point(2,3),1)
    r.should == [[1, 1], [1, 1], [1, 1]]

    r = resize2d(r,point(3,3),2)
    r.should == [[1, 1, 2], [1, 1, 2], [1, 1, 2]]

    r = resize2d(r,point(3,2),3)
    r.should == [[1, 1, 2], [1, 1, 2]]

    r = [[1],[2,2],[3,3,3]]
    r = resize2d(r,point(3,4),4)
    r.should == [[1, 4, 4], [2, 2, 4], [3, 3, 3], [4, 4, 4]]
  end

  it "subarray2d string" do
    r = ["123", "456", "789"]
    subarray2d(r,rect(1,1,2,2)).should == ["56", "89"]
    subarray2d(r,rect(1,2,2,2)).should == ["89"]
    subarray2d(r,rect(2,1,2,2)).should == ["6", "9"]

    subarray2d(r,rect(-1,1,2,2)).should == ["4", "7"]
    subarray2d(r,rect(1,-1,2,2)).should == ["23"]
  end

  it "subarray2d array" do
    r = [[1,2,3], [4,5,6], [7,8,9]]
    subarray2d(r,rect(1,1,2,2)).should == [[5,6], [8,9]]
    subarray2d(r,rect(1,2,2,2)).should == [[8,9]]
    subarray2d(r,rect(2,1,2,2)).should == [[6], [9]]

    subarray2d(r,rect(-1,1,2,2)).should == [[4], [7]]
    subarray2d(r,rect(1,-1,2,2)).should == [[2,3]]
  end

  it "gen_array2d string" do
    gen_array2d(point(1,1), "-=").should == ["-"]
    gen_array2d(point(3,3), "-=").should == ["-=-", "=-=", "-=-"]
    gen_array2d(point(4,4), "123").should == ["1231", "2312", "3123", "1231"]
  end

  it "gen_array2d array" do
    gen_array2d(point(1,1), [1, 2]).should == [[1]]
    gen_array2d(point(3,3), [1, 2]).should == [[1,2,1], [2,1,2], [1,2,1]]
    gen_array2d(point(4,4), [1, 2, 3]).should == [[1, 2, 3, 1], [2, 3, 1, 2], [3, 1, 2, 3], [1,2,3,1]]
  end
end
end
