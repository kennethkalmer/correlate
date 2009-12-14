require 'spec_helper'

class Foo; end
module Bar
  class Foo; end
end

describe Correlate::Correlation, "classify" do
  before(:each) do
    @correlation = Correlate::Correlation.new
  end

  it "should work on top level constants" do
    @correlation.target = 'Foo'
    @correlation.target_class.should == Foo
  end

  it "should work on nested classes" do
    @correlation.target = 'Bar::Foo'
    @correlation.target_class.should == Bar::Foo
  end
end
