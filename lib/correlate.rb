# = Correlate
#
# Correlate is an experiment in loosely defining relationships between documents
# stored in CouchDB using CouchRest's ExtendedDocument, as well as relationships
# between these documents and ActiveRecord models.
#
# == Overview
#
# Relationships are defined as an array of hashes, each hash containing a +rel+
# and +href+ key. This is modelled on HTML's success in loosely defining
# relationships between different documents.
#
# A sample might look like this:
#
#
#  {
#    ...
#    "links" : [
#     { "rel" : "another_doc", "href" : "<uuid>" },
#     { "rel" : "important", "href" : "<uuid>" }
#     ...
#    ]
#    ...
#  }
#
# == Using correlate
#
# Correlate presents itself as a mixin for CouchRest::ExtendedDocument classes,
# as well as ActiveRecord models.
#
# === Using with CouchRest::ExtendedDocument
#
#   class SomeDocument < CouchRest::ExtendedDocument
#     include Correlate
#
#     related_to do
#       some :other_documents, :class => 'OtherDocument', :rel => 'other_document'
#       a :parent_document, :class => 'ParentDocument'
#     end
#   end
#
#
# === Using with ActiveRecord::Base
#
#   class Model < ActiveRecord::Base
#     include Correlate
#
#     related_to do
#       some :documents, :class => 'Document', :rel => 'model'
#     end
#   end
#
# When correlating ActiveRecord models with CouchRest documents, it is required
# that the 'reverse correlation' is specified in the CouchRest class.
#
# @see Correlate::Relationships::CouchRest
# @see Correlate::Relationships::ActiveRecord
module Correlate

  VERSION = '0.0.0'

  autoload :Relationships, 'correlate/relationships'
  autoload :Links,         'correlate/links'
  autoload :Correlation,   'correlate/correlation'
  autoload :Validator,     'correlate/validator'

  def self.included( base )
    base.extend( ClassMethods )
  end

  module ClassMethods

    # Depending on the containing class, this method configures either a
    # Correlate::Relationships::CouchRest or a
    # Correlate::Relationships::ActiveRecord.
    #
    # @see Correlate::Relationships::CouchRest
    # @see Correlate::Relationships::ActiveRecord
    def related_to( &block )
      Correlate::Relationships.configure!( self, &block )
    end

    # @private
    def correlations
      @correlations ||= []
    end

    # Determine the matching correlation for the provided object.
    # @return [ Correlate::Correlation, nil ]
    # @see Correlate::Correlation#matches?
    def correlation_for( object )
      self.correlations.detect { |c| c.matches?( object ) }
    end

  end

end
