module Correlate
  class Correlation
    attr_accessor :name, :type, :klass, :rel, :id_method

    def matches?( obj )
      case obj
      when CouchRest::ExtendedDocument
        klass == obj['couchrest-type']
      when Hash
        obj['rel'] == rel
      else
        klass == obj.class.name
      end
    end

    def rel
      @rel || @name
    end

    def id_method
      @id_method || :id
    end

    def correlate( obj )
      classify.get( obj['href'] )
    end

    private

    def classify
      raise "Class #{klass} not found" if !Object.const_defined?( klass.to_sym )

      Object.const_get( klass.to_sym )
    end

  end
end
