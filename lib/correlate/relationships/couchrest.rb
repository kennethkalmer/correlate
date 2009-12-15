module Correlate
  module Relationships

    autoload :Validator, 'correlate/relationships/couchrest/validator'

    # Configure relationships between CouchRest::ExtendedDocument classes, as
    # well as between CouchRest::ExtendedDocument & ActiveRecord::Base classes.
    #
    # Using this correlation in a CouchRest::ExtendedDocument creates a +links+
    # property that is used for storing the correlations between this document
    # and others.
    #
    # It also creates a +rel+ view for the class that emits two keys: +rel+ &
    # +href+, which is used for bulk lookups and loading of documents.
    #
    # == Notes
    #
    # To use the validations provided by Correlate you need to include
    # +CouchRest::Validation+ into your classes.
    #
    # @see #a
    # @see #some
    class CouchRest

      class << self

        def configure!( klass, &block )

          # Add our property
          klass.property :links, :type => 'Correlate::Links', :default => Correlate::Links.new( klass )

          # Setup our conveniences
          relationships = new( klass )
          relationships.instance_eval( &block )
          relationships.build_validators
          relationships.build_views

          # Make sure our links array is properly casted
          klass.class_eval <<-EOF, __FILE__, __LINE__
            def links
              unless self[:links].respond_to?( :owner )
                self[:links] = Correlate::Links.new( self.class, self[:links], self )
              end

              self[:links].owner ||= self

              self[:links]
            end
          EOF
        end

      end

      def initialize( klass )
        @klass = klass
      end

      # Specify that this document will have multiple documents of said relationship.
      #
      # @example Defining correlations and using them
      #   class SomeDocument < CouchRest::ExtendedDocument
      #     include Correlate
      #
      #     related_to do
      #       some :other_documents, :class => 'OtherDocument, :rel => 'other_document'
      #     end
      #   end
      #
      #   doc = SomeDocument.new
      #   doc.other_documents # => []
      #
      #   other_doc = OtherDocument.get( '885387e892e63f4b6d31dbc877533099' )
      #   doc.other_documents << other_doc
      #
      #   doc.other_documents # => [ <OtherDocument#12121212> ]
      #
      # @param [Symbol] name of the relationship
      # @param [Hash] options for the relationship
      # @option options [String] :class the class of the related document/model
      # @option options [String] :rel the value of the +rel+ key in the related hash
      # @option options [Fixnum] :requires (nil) a number of documents required
      # @option options [Symbol] :id_method (:id) name of a method use to retrieve the 'foreign key' value from documents added to the relationship
      # @option options [Symbol] :load_via (:get/:find) name of the class method used to retreive related documents (defaults to :get for CouchRest::ExtendedDocument, :find for ActiveRecord::Base)
      # @option options [Symbol] :recipocal (false) whether to update the links on the corresponding object as well
      def some( name, options = {} )
        options[:source] = @klass

        correlation = Correlate::Relationships.build_correlation( name, :some, options )
        @klass.correlations << correlation

        @klass.class_eval <<-EOF, __FILE__, __LINE__
          def #{name}( raw = false )
            correlations = self.links.rel( '#{correlation.rel}' )

            unless raw
              c = self.class.correlation_for( correlations.first )
              correlations = c.bulk_correlate( correlations ) unless c.nil?
            end

            correlations
          end
        EOF
      end

      # Specify that this document will have a single document of said relationship.
      #
      # @example Defining correlations and using them
      #   class OtherDocument < CouchRest::ExtendedDocument
      #     include Correlate
      #
      #     related_to do
      #       a :some_document, :class => 'SomeDocument'
      #     end
      #   end
      #
      #   doc = OtherDocument.new
      #   doc.some_document # => nil
      #
      #   some_doc = SomeDocument.get( '885387e892e63f4b6d31dbc877533099' )
      #   doc.some_document = some_doc
      #
      #   doc.some_document # => [ <SomeDocument#12121212> ]
      #
      # @param [Symbol] name of the relationship
      # @param [Hash] options for the relationship
      # @option options [String] :class the class of the related document/model
      # @option options [String] :rel (name) the value of the +rel+ key in the related hash
      # @option options [Fixnum] :required (false) whether required or not
      # @option options [Symbol] :id_method (:id) name of a method use to retrieve the 'foreign key' value from documents added to the relationship
      # @option options [Symbol] :load_via (:get/:find) name of the class method used to retreive related documents (defaults to :get for CouchRest::ExtendedDocument, :find for ActiveRecord::Base)
      # @option options [Symbol] :recipocal (false) whether to update the links on the corresponding object as well
      def a( name, options = {} )
        options[:source] = @klass

        correlation = Correlate::Relationships.build_correlation( name, :a, options )
        @klass.correlations << correlation

        @klass.class_eval <<-EOF, __FILE__, __LINE__
          def #{name}=( object )
            self.links.replace( object )
          end

          def #{name}( raw = false )
            correlation = self.links.rel( '#{correlation.rel}' ).first
            return if correlation.nil?

            correlation = self.class.correlation_for( correlation ).correlate( correlation ) unless raw

            correlation
          end
        EOF
      end

      # @private
      def build_validators
        if @klass.included_modules.include?( ::CouchRest::Validation )

          fields = [ :links ]
          opts = @klass.opts_from_validator_args( fields )
          @klass.add_validator_to_context( opts, fields, Validator )
        end
      end

      # @private
      def build_views
        @klass.view_by :rel,
          :map => <<-MAP
            function( doc ) {
              if( doc['couchrest-type'] == '#{@klass}' ) {
                doc.links.forEach(function(link) {
                  emit([ link.rel, link.href ], 1);
                });
              }
            }
          MAP
      end

    end
  end
end
