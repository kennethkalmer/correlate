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

    # Whether the correlation should be recipocal
    attr_accessor :recipocal

    # Name of a view used to load documents from ActiveRecord's side
    attr_accessor :view

    # Determine if this correlation can be used for the provided object
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

    # Return the +rel+ used for this correlation. Uses #name if #rel is nil
    def rel
      (@rel || @name).to_s
    end

    # Return the method name used for determining the href value of the correlation.
    # Defaults to +:id+.
    def id_method
      @id_method || :id
    end

    # Correlate the object from its rel/href values.
    def correlate( object )

      if direction == { :active_record => :couchdb }

        raise ArgumentError, "#{target} doesn't correlate with #{source}" unless bidirectional?

        return target_class.by_rel :key => [ opposite.rel, object.send( opposite.id_method ) ]
      end

      return target_class.send( load_via, object['href'] )
    end

    # Correlate the objects from their rel/href values
    def bulk_correlate( objects )
      results = objects.inject([]) do |results, obj|
        results << target_class.send( load_via, obj['href'] )
      end.compact
    end

    # Do we have a mutual correlation (ie defined in both classes)
    def bidirectional?
      target_class.included_modules.include?( Correlate ) && !opposite.nil?
    end

    # Determine the 'reverse correlation' from the target class
    def opposite
      target_class.correlations.detect { |c| c.target == source.name }
    end

    # Conveniently show the 'direction' of the correlation in terms of classes
    # @return [ Hash ] { :couchdb => :activerecord } or vice versa or couch to couch.
    def direction
      f = source_class.ancestors.include?( CouchRest::ExtendedDocument ) ? :couchdb : :active_record
      t = target_class.ancestors.include?( CouchRest::ExtendedDocument ) ? :couchdb : :active_record

      { f => t }
    end

    def target_class
      target.split('::').inject( Object ) do |parent, klass|
        raise "Class #{klass} not found" if !parent.const_defined?( klass.to_sym )

        parent.const_get( klass.to_sym )
      end
    end

    def source_class
      source
    end

    def recipocal?
      @recipocal || false
    end

    private

    # The class method used to load instances of the documents.
    def load_via
      @load_via ||= (
        target_class.ancestors.include?( CouchRest::ExtendedDocument ) ? :get : :find
      )
    end
  end
end
