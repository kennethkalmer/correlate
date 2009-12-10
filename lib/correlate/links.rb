module Correlate
  class Links

    instance_methods.each { |m| undef_method m unless m =~ /(^__|^send$|^object_id$)/ }

    def initialize( klass, array = [] )
      @klass = klass
      @target_array = array
    end

    def rel( rel )
      clone( @target_array.select { |link| link['rel'] == rel } )
    end

    def <<( obj )
      write_target.push({ 'rel' => rel_for_object( obj ), 'href' => id_for_object( obj ) })
    end

    def replace( obj )
      rel = rel_for_object( obj )

      write_target.reject! { |l| l['rel'] == rel }

      self.<< obj
    end

    def correlation_for_object( obj )
      @klass.correlations.detect do |correlation|
        correlation.matches?( obj )
      end
    end

    def __debug__
      {
        :object_id => object_id,
        :klass => @klass,
        :target_array => @target_array,
        :original_copy => @original_copy,
        :original_copy_object_id => @original_copy.object_id
      }
    end

    protected

    def clone( array )
      Links.new( @klass, array ).subset_of( @original_copy || self )
    end

    def subset_of( links_instance )
      @original_copy = links_instance
    end

    def rel_for_object( obj )
      c = correlation_for_object( obj )

      if c.nil? && obj.instance_of?( Hash )
        obj['rel']
      else
        c.rel
      end
    end

    def id_for_object( obj )
      c = correlation_for_object( obj )
      if c.nil? && obj.instance_of?( Hash )
        obj['href']
      else
        obj.send( c.id_method )
      end
    end

    def write_target
      @original_copy || @target_array
    end

    def method_missing( name, *args, &block )
      @target_array.send( name, *args, &block )
    end
  end
end
