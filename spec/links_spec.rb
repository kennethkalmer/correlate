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

  describe "recipocating" do
    before(:each) do
      @jack = Person.create( :name => 'Jack' )
      @jill = Person.create( :name => 'Jill' )

      @jack.links << @jill
    end

    it "should recipocate updates" do
      @jack.links.should == [{ 'rel' => 'person', 'href' => @jill.id }]
      @jill.links.should == [{ 'rel' => 'person', 'href' => @jack.id }]

      Person.get( @jack.id ).links.should == [{ 'rel' => 'person', 'href' => @jill.id }]
      Person.get( @jill.id ).links.should == [{ 'rel' => 'person', 'href' => @jack.id }]
    end

    it "should recipocate deletes" do
      @jack.links.delete( @jill )

      @jack.links.should be_empty
      @jill.links.should be_empty

      Person.get( @jack.id ).links.should be_empty
      Person.get( @jill.id ).links.should be_empty
    end

    it "should recipocate replacements"

    it "should delay recipocations of new objects until saved (when added to existing links)" do
      rob = Person.new( :name => 'Rob' )
      @jill.links << rob

      @jill.links.size.should be(1)
      rob.links.should == [{ 'rel' => 'person', 'href' => @jill.id }]

      rob.save

      @jill.links.should == [{ 'rel' => 'person', 'href' => @jack.id }, { 'rel' => 'person', 'href' => rob.id }]
    end

    it "should delay recipocations of new objects until saved (when added to new links)" do
      rob = Person.new( :name => 'Rob' )
      rob.links << @jill

      @jill.links.size.should be(1)
      rob.links.should == [{ 'rel' => 'person', 'href' => @jill.id }]

      rob.save

      @jill.links.should == [{ 'rel' => 'person', 'href' => @jack.id }, { 'rel' => 'person', 'href' => rob.id }]
    end
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
