module Correlate
  module Relationships

    # Used to define relationships between ActiveRecord::Base models and
    # CouchRest::ExtendedDocument classes.
    #
    # == Important note
    #
    # Unlike normal correlations, when correlating an ActiveRecord model with
    # a CouchRest document, the 'reverse correlation' needs to be specified in
    # in the CouchRest model.
    #
    # @see #a
    # @see #some
    class ActiveRecord

      autoload :CollectionProxy, 'correlate/relationships/active_record/collection_proxy'

      class << self

        def configure!( klass, &block )

          # Setup our conveniences
          relationships = new( klass )
          relationships.instance_eval( &block )
        end

      end

      def initialize( klass )
        @klass = klass
      end

      # Specify that this model will have multiple documents of said relationship.
      # This is akin to ActiveRecord's +has_many associations+
      #
      # @example Defining correlations and using them
      #   class MyModel < ActiveRecord::Base
      #     include Correlate
      #
      #     related_to do
      #       some :other_documents, :class => 'OtherDocument', :rel => 'my_model'
      #     end
      #   end
      #
      #   class OtherDocument < CouchRest::ExtendedDocument
      #     include Correlate
      #
      #     related_to do
      #       a :my_model, :class => 'MyModel'
      #     end
      #   end
      #
      #   doc = OtherDocument.new
      #   doc.my_model # => nil
      #
      #   me = MyModel.find( 1 )
      #   doc.my_model = me
      #
      #   doc.me_model # => <MyModel#12121212>
      #
      #   me.other_documents # => [ <OtherDocument#121212121> ]
      #
      # @param [Symbol] name of the relationship
      # @param [Hash] options for the relationship
      # @option options [String] :class the class of the related document/model
      # @option options [String] :rel the value of the +rel+ key in the related hash
      # @option options [Symbol] :id_method (:id) name of a method use to retrieve the 'foreign key' value from documents added to the relationship
      # @option options [Symbol] :load_via (:get) name of the class method used to retreive related documents
      def some( *args )
        name = args.shift
        opts = args.empty? ? {} : args.last
        opts[:source] = @klass

        correlation = Correlate::Relationships.build_correlation( name, :some, opts )
        @klass.correlations << correlation

        @klass.class_eval <<-EOF, __FILE__, __LINE__
          def #{name}( raw = false )
            local_correlation = self.class.correlations.detect { |c| c.name == :#{name} }

            Correlate::Relationships::ActiveRecord::CollectionProxy.new self, local_correlation
          end
        EOF
      end

      # Specify that this model will have a single document of said relationship.
      # This is akin to ActiveRecord's +belongs_to or has_one associations+.
      #
      # @example Defining correlations and using them
      #   class MyModel < ActiveRecord::Base
      #     include Correlate
      #
      #     related_to do
      #       a :journal, :class => 'Journal', :rel => 'my_model'
      #     end
      #   end
      #
      #   class Journal < CouchRest::ExtendedDocument
      #     include Correlate
      #
      #     related_to do
      #       some :my_models, :class => 'MyModel', :rel => 'my_model'
      #     end
      #   end
      #
      #   doc = Journal.new
      #   doc.my_models # => []
      #
      #   me = MyModel.find( 1 )
      #   doc.my_models << me
      #
      #   doc.my_models # => [ <MyModel#12121212> ]
      #
      #   me.journal # => <Journal#121212121>
      #
      # @param [Symbol] name of the relationship
      # @param [Hash] options for the relationship
      # @option options [String] :class the class of the related document/model
      # @option options [String] :rel (name) the value of the +rel+ key in the related hash
      # @option options [Symbol] :id_method (:id) name of a method use to retrieve the 'foreign key' value from documents added to the relationship
      # @option options [Symbol] :load_via (:get) name of the class method used to retreive related documents
      def a( name, options = {} )
        options[:source] = @klass

        @klass.correlations << Correlate::Relationships.build_correlation( name, :a, options )

        @klass.class_eval <<-EOF, __FILE__, __LINE__
          def #{name}=( object )
            self.links.replace( object )
          end

          def #{name}( raw = false )
            correlation = self.links.rel( '#{name}' ).first
            return if correlation.nil?

            correlation = self.links.correlation_for_object( correlation ).correlate( correlation ) unless raw

            correlation
          end
        EOF
      end

    end
  end
end
