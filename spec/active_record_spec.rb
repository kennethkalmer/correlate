require 'spec_helper'

describe Correlate, ActiveRecord do
  fixtures :article, :comment

  before(:each) do
    @article = Article.create( :title => 'Correlations in C' )
  end

  it "should have an empty association" do
    @article.comments.should be_empty
  end

  it "should accept a new associated document" do
    comment = Comment.create( :comment => 'awesome' )
    @article.comments << comment

    @article.comments.should == [ comment ]
  end
end
