require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Correlate do
  fixtures :person

  describe "extends classes" do
    it "to track correlations" do
      Person.correlations.should_not be_empty

      correlation = Person.correlations.first
      correlation.should be_a_kind_of( Correlate::Correlation )
      correlation.type.should == :some
      correlation.name.should == :people
      correlation.klass.should == 'Person'
    end
  end

  describe "to self" do
    before(:each) do
      @person = Person.new
    end

    it "should have an empty array" do
      @person.people.should be_a_kind_of( Array )
      @person.people.should be_empty
    end

    it "should accept new associations" do
      person = Person.create :name => 'John'
      @person.people << person

      @person.links.should == [{ 'rel' => 'person', 'href' => person.id }]
      @person.save!

      Person.get( @person.id ).links.should == [{ 'rel' => 'person', 'href' => person.id }]
    end

    it "should load objects from associations" do
      person = Person.create :name => 'Jack'
      @person.people << person
      @person.save!

      @person.people.should == [ person ]
    end
  end
end
