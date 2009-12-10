require 'spec_helper'

describe Correlate::Links do
  fixtures :person

  before(:each) do
    @blank = Correlate::Links.new( Person )

    @links = Correlate::Links.new( Person )
    @links << { 'rel' => 'foo', 'href' => 'bar' }
  end

  it "should be able to find by rel" do
    @links.rel( 'foo' ).should == [{ 'rel' => 'foo', 'href' => 'bar' }]
  end

  it "should be able to replace by rel" do
    @links.replace({ 'rel' => 'foo', 'href' => 'baz' })

    @links.should == [{ 'rel' => 'foo', 'href' => 'baz' }]
  end
end
