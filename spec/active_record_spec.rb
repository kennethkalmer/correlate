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

  it "should be reciprocal" do
    comment = Comment.create( :comment => 'extreme' )
    comment.article = @article

    comment.article.should == @article
    comment.save

    Comment.get( comment.id ).article.should == @article
  end
end
