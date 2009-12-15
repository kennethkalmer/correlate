require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Correlate, "CouchDB" do

  describe "extends classes" do
    fixtures :person

    it "to track correlations" do
      Person.correlations.should_not be_empty

      correlation = Person.correlations.first
      correlation.should be_a_kind_of( Correlate::Correlation )
      correlation.type.should == :some
      correlation.name.should == :people
      correlation.target.should == 'Person'
      correlation.source.should == Person
      correlation.should be_recipocal
    end

    it "should define a view for looking up rels" do
      Person.should have_view('by_rel')
    end
  end

  describe "to self & recipocal" do
    fixtures :person

    before(:each) do
      @person = Person.create( :name => 'Ken' )
    end

    it "should have an empty array" do
      @person.people.should be_a_kind_of( Array )
      @person.people.should be_empty
    end

    it "should accept new associations" do
      person = Person.create :name => 'John'
      @person.people << person

      @person.links.should == [{ 'rel' => 'person', 'href' => person.id }]
      person.links.should == [{ 'rel' => 'person', 'href' => @person.id }]
      @person.save!

      Person.get( @person.id ).links.should == [{ 'rel' => 'person', 'href' => person.id }]
      Person.get( person.id ).links.should == [{ 'rel' => 'person', 'href' => @person.id }]
    end

    it "should load objects from associations" do
      person = Person.create :name => 'Jack'
      @person.people << person
      @person.save!

      @person.people.should == [ person ]
      person.people.should == [ @person ]
    end

    it "should have the raw associations" do
      person = Person.create :name => 'Jack'
      @person.people << person
      @person.save!

      @person.people( true ).should == [{'rel' => 'person', 'href' => person.id }]
      person.people( true ).should == [{'rel' => 'person', 'href' => @person.id }]
    end
  end

  describe "to some others" do
    fixtures :news_feed, :reader

    before(:each) do
      @reader = Reader.new
    end

    it "should have an empty array" do
      @reader.news_feeds.should be_empty
    end

    it "should accept new associations" do
      feed = NewsFeed.create :url => 'http://planet.couchdb.com/atom.xml'
      @reader.news_feeds << feed

      @reader.links.should == [{ 'rel' => 'news_feed', 'href' => feed.id }]
      @reader.save!

      Reader.get( @reader.id ).links.should == [{ 'rel' => 'news_feed', 'href' => feed.id }]
    end

    it "should load objects from associations" do
      feed = NewsFeed.create :url => 'http://planet.couchdb.com/atom.xml'
      @reader.news_feeds << feed
      @reader.save!

      @reader.news_feeds.should == [ feed ]
    end

    it "should have access to the raw accosiations" do
      feed = NewsFeed.create :url => 'http://planet.couchdb.com/atom.xml'
      @reader.news_feeds << feed
      @reader.save!

      @reader.news_feeds( true ).should == [{ 'rel' => 'news_feed', 'href' => feed.id }]
    end
  end

  describe "to another" do
    fixtures :news_feed, :crawler

    before(:each) do
      @feed = NewsFeed.new( :url => 'http://planet.couchdb.com/atom.xml' )
    end

    it "should have a nil instance" do
      @feed.crawler.should be_nil
    end

    it "should accept a new instance" do
      crawler = Crawler.create :host => 'foo.example.com'
      @feed.crawler = crawler

      @feed.links.should == [{ 'rel' => 'crawler', 'href' => crawler.id }]
      @feed.save!

      NewsFeed.get( @feed.id ).links.should == [{ 'rel' => 'crawler', 'href' => crawler.id }]
    end

    it "should load the object from the association" do
      crawler = Crawler.create :host => 'foo.example.com'
      @feed.crawler = crawler
      @feed.save!

      @feed.crawler.should == crawler
    end

    it "should give access to the raw association" do
      crawler = Crawler.create :host => 'foo.example.com'
      @feed.crawler = crawler
      @feed.save!

      @feed.crawler( true ).should == { 'rel' => 'crawler', 'href' => crawler.id }
    end
  end

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
