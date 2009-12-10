module Correlate
  class Relationships

    class << self

      def configure!( klass, &block )

        # Add our property
        klass.property :links, :type => 'Correlate::Links', :default => Correlate::Links.new( klass )

        # Setup our conveniences
        new( klass ).instance_eval( &block )
      end

    end

    def initialize( klass )
      @klass = klass
    end

    def some( *args )
      name = args.shift
      opts = args.empty? ? {} : args.last

      correlation = Correlation.new
      correlation.name = name
      correlation.type = :some
      correlation.klass = opts[:class]
      correlation.rel = opts[:rel]
      correlation.id_method = opts[:id_method]

      @klass.correlations << correlation

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

  end
end
