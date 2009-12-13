module Correlate
  class Validator < ::CouchRest::Validation::GenericValidator

    def initialize( field_name, options = {} )
      super
      @field_name, @options = field_name, options
    end

    def call( target )
      results = []

      target.class.correlations.each do |correlation|
        case correlation.type
        when :some
          results << validate_some( correlation, target )
        when :a
          results << validate_a( correlation, target )
        end
      end

      !results.any? { |r| r == false }
    end

    def validate_some( correlation, target )
      results = true

      case correlation.requires
      when Fixnum
        unless target.send( correlation.name, true ).size >= correlation.requires
          target.errors.add( correlation.name, "Requires at least #{correlation.requires} #{correlation.name}" )
          results = false
        end
      end

      results
    end

    def validate_a( correlation, target )
      results = true

      if correlation.required && target.send( correlation.name ).nil?
        target.errors.add( correlation.name, "is required" )
        results = false
      end

      results
    end
  end
end
