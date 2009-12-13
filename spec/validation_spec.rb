require 'spec_helper'

describe Correlate do
  describe "validations for 'some'" do
    fixtures :student, :course

    before(:each) do
      @student = Student.new
    end

    it "should be enforced" do
      @student.should_not be_valid
    end

    it "should be met" do
      @student.enlistments << Course.create( :name => 'B.Sc Foo' )
      @student.should be_valid
    end
  end

  describe "validations for 'a'" do
    fixtures :comment, :article

    before(:each) do
      @comment = Comment.new
    end

    it "should be enforced" do
      @comment.should_not be_valid
    end

    it "should be met" do
      article = Article.create( :title => 'Validating the system' )
      @comment.article = article
      @comment.should be_valid
    end
  end
end
