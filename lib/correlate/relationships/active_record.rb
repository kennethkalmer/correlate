module Correlate
  module Relationships
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

    end
  end
end
