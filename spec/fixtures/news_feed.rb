# The news feeds read by a reader, and has a crawler that updates it
class NewsFeed < CouchRest::ExtendedDocument

  include Correlate

  use_database DB

  property :url

  related_to do
    a :crawler, :class => 'Crawler'
  end
end
