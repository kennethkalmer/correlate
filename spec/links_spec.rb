require 'spec_helper'

describe Correlate::Links do
  fixtures :person

  before(:each) do
    @links = Correlate::Links.new( Person )
    @links << { 'rel' => 'foo', 'href' => 'bar' }
  end

  it "should be able to find by rel" do
    @links.rel( 'foo' ).should == [{ 'rel' => 'foo', 'href' => 'bar' }]
  end

  it "should not find false positives" do
    @links.rel( 'bar' ).should == []
  end

  it "should return a clone" do
    @links.rel( 'bar' ).object_id.should_not == @links.object_id
  end

  it "should be able to replace by rel" do
    @links.replace({ 'rel' => 'foo', 'href' => 'baz' })

    @links.should == [{ 'rel' => 'foo', 'href' => 'baz' }]
  end

  it "should be able to delete by rel" do
    @links.delete({ 'rel' => 'foo', 'href' => 'bar' })
    @links.should be_empty
  end

  describe "internals" do
    it "should provide a clone" do
      clone = @links.send( :clone, [] )
      clone.__debug__[:original_copy].should == @links
    end

    it "should write to the original copy" do
      clone = @links.send( :clone, [] )
      clone << { 'rel' => 'baz', 'href' => 'foo' }
      clone.should == [{ 'rel' => 'baz', 'href' => 'foo' }]
      @links.should == [
        { 'rel' => 'foo', 'href' => 'bar' },
        { 'rel' => 'baz', 'href' => 'foo' }
      ]
    end
  end
end
