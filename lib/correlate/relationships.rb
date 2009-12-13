module Correlate
  module Relationships

    autoload :CouchRest, 'correlate/relationships/couchrest'
    autoload :ActiveRecord, 'correlate/relationships/active_record'

    class << self

      def configure!( klass, &block )
        if klass.ancestors.include?( ::CouchRest::ExtendedDocument )
          Correlate::Relationships::CouchRest.configure! klass, &block
        else
          if defined?( ::ActiveRecord ) && klass.ancestors.include?( ::ActiveRecord::Base )
            Correlate::Relationships::ActiveRecord.configure! klass, &block
          end
        end
      end

      def build_correlation( name, type, opts )
        correlation = Correlation.new
        correlation.name = name
        correlation.type = type
        correlation.target = opts[:class]
        correlation.source = opts[:source]
        correlation.rel = opts[:rel]
        correlation.id_method = opts[:id_method]
        correlation.requires = opts[:requires]
        correlation.required = opts[:required]

        correlation
      end

    end

  end
end
