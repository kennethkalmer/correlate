class Comment < CouchRest::ExtendedDocument

  use_database DB

  include Correlate
  include CouchRest::Validation

  related_to do
    a :article, :class => 'Article', :required => true
  end
end
