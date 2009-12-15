# Test on a 'simple social graph'
class Person < CouchRest::ExtendedDocument

  use_database DB

  include Correlate

  related_to do
    some :people, :class => 'Person', :rel => 'person', :recipocal => true
  end
end
