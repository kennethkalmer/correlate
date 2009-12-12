module Correlate
  module Relationships
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
        end

      end

      def initialize( klass )
        @klass = klass
      end

      def some( *args )
        name = args.shift
        opts = args.empty? ? {} : args.last
        opts[:source] = @klass

        @klass.correlations << Correlate::Relationships.build_correlation( name, :some, opts )

        @klass.class_eval <<-EOF, __FILE__, __LINE__
          def #{name}( raw = false )
            correlations = self.links.rel( '#{name}' )

            correlations.map! do |c|
              self.links.correlation_for_object( c ).correlate( c )
            end unless raw

            correlations
          end
        EOF
      end

      def a( *args )
        name = args.shift
        opts = args.empty? ? {} : args.last
        opts[:source] = @klass

        @klass.correlations << Correlate::Relationships.build_correlation( name, :a, opts )

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

      def build_validators
        if @klass.included_modules.include?( ::CouchRest::Validation )

          fields = [ :links ]
          opts = @klass.opts_from_validator_args( fields )
          @klass.add_validator_to_context( opts, fields, Correlate::Validator )
        end
      end

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
