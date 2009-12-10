require 'spec_helper'

describe Correlate::Relationships do
  fixtures :blank_doc

  it "should be able to configure a class" do
    relationships = lambda {
      some :foo
    }

    Correlate::Relationships.configure!( BlankDoc, &relationships )

    link_property = BlankDoc.properties.detect { |p| p.name == 'links' }
    link_property.should_not be_nil
    link_property.type.should == 'Correlate::Links'
  end
end

