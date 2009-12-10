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

    end

  end
end
