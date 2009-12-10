# A reader of articles from different feeds
class Reader < CouchRest::ExtendedDocument

  include Correlate

  use_database DB

  related_to do
    some :news_feeds, :class => 'NewsFeed', :rel => 'news_feed'
  end
end
