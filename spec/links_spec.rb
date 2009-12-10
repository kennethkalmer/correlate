require 'spec_helper'

describe Correlate::Links do
  before(:each) do
    @blank = Correlate::Links.new( Person )

    @links = Correlate::Links.new( Person )
    @links << { 'rel' => 'foo', 'href' => 'bar' }
  end

  it "should be able to find by rel" do
    @links.rel( 'foo' ).should == [{ 'rel' => 'foo', 'href' => 'bar' }]
  end
end
