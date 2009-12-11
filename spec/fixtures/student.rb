class Student < CouchRest::ExtendedDocument

  use_database DB

  include Correlate
  include CouchRest::Validation

  related_to do
    some :enlistments, :class => 'Course', :rel => 'course', :requires => 1
  end
end
