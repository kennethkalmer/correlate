# The news feeds read by a reader
class NewsFeed < CouchRest::ExtendedDocument

  include Correlate

  use_database DB

  property :url

  related_to do
    a :reader
  end
end
