module Correlate
  class Correlation
    # Class owning the correlation
    attr_accessor :source

    # Name of the correlation
    attr_accessor :name

    # Type of relationship
    attr_accessor :type

    # Class the relationship targets
    attr_accessor :target

    # +rel+ attribute used to distinguish this correlation
    attr_accessor :rel

    # Method used to extract the 'id' from instances add to the correlation (defaults to +id+)
    attr_accessor :id_method

    # For +some+ relationships specify how many instances are required
    attr_accessor :requires

    # For +a+ relationships specify if required
    attr_accessor :required

    # Class method on the target class used when loading single instances
    # (defaults to +get+ for CouchRest docs, and +find+ for ActiveRecord models)
    attr_accessor :load_via

    # Name of a view used to load documents from ActiveRecord's side
    attr_accessor :view

    def matches?( obj )
      case obj
      when CouchRest::ExtendedDocument
        target == obj['couchrest-type']
      when Hash
        obj['rel'] == rel
      else
        target == obj.class.name
      end
    end

    def rel
      (@rel || @name).to_s
    end

    def id_method
      @id_method || :id
    end

    def correlate( *objects )
      if direction == { :active_record => :couchdb }

        raise ArgumentError, "#{target} doesn't correlate with #{source}" unless bidirectional?

        if objects.size == 1
          obj = objects.shift

          return target_class.by_rel :key => [ opposite.rel, obj.send( opposite.id_method ) ]
        end
      end

      if objects.size == 1
        obj = objects.pop
        return target_class.send( load_via, obj['href'] )
      end
    end

    def bidirectional?
      target_class.included_modules.include?( Correlate ) && !opposite.nil?
    end

    def opposite
      target_class.correlations.detect { |c| c.target == source.name }
    end

    def direction
      f = source_class.ancestors.include?( CouchRest::ExtendedDocument ) ? :couchdb : :active_record
      t = target_class.ancestors.include?( CouchRest::ExtendedDocument ) ? :couchdb : :active_record

      { f => t }
    end

    private

    def load_via
      @load_via ||= (
        target_class.ancestors.include?( CouchRest::ExtendedDocument ) ? :get : :find
      )
    end

    def target_class
      raise "Class #{target} not found" if !Object.const_defined?( target.to_sym )

      Object.const_get( target.to_sym )
    end

    def source_class
      source
    end

  end
end
