module Correlate
  class Validator < ::CouchRest::Validation::GenericValidator

    def initialize( field_name, options = {} )
      super
      @field_name, @options = field_name, options
    end

    def call( target )
      results = true

      target.class.correlations.each do |correlation|
        case correlation.requires
        when Fixnum
          unless target.send( correlation.name, true ).size >= correlation.requires
            target.errors.add( correlation.name, "Requires at least #{correlation.requires} #{correlation.name}" )
            results = false
          end
        end
      end

      results
    end
  end
end
