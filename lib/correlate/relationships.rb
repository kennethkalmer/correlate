module Correlate
  class Relationships

    class << self

      def configure!( klass, &block )

        # Add our property
        klass.property :links, :type => 'Correlate::Links', :default => Correlate::Links.new( klass )

        # Setup our conveniences
        relationships = new( klass )
        relationships.instance_eval( &block )
        relationships.build_validators
      end

    end

    def initialize( klass )
      @klass = klass
    end

    def some( *args )
      name = args.shift
      opts = args.empty? ? {} : args.last

      @klass.correlations << build_correlation( name, :some, opts )

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

      @klass.correlations << build_correlation( name, :a, opts )

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
      if @klass.included_modules.include?( CouchRest::Validation )
        fields = [ :links ]
        opts = @klass.opts_from_validator_args( fields )
        @klass.add_validator_to_context( opts, fields, Correlate::Validator )
      end
    end

    protected

    def build_correlation( name, type, opts )
      correlation = Correlation.new
      correlation.name = name
      correlation.type = type
      correlation.klass = opts[:class]
      correlation.rel = opts[:rel]
      correlation.id_method = opts[:id_method]
      correlation.requires = opts[:requires]

      correlation
    end

  end
end
