class Comment < CouchRest::ExtendedDocument

  use_database DB

  include Correlate

  related_to do
    a :article, :class => 'Article'
  end
end
