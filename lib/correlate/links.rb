module Correlate
  # Thin proxy around the array of links.
  class Links

    instance_methods.each { |m| undef_method m unless m =~ /(^__|^send$|^object_id$)/ }

    def initialize( klass, array = [] )
      @klass = klass
      @target_array = array
    end

    # Extract all the matching links for rel.
    #
    # @param [String] rel
    # @return [ Correlate::Links ] for matching links
    def rel( rel )
      clone( @target_array.select { |link| link['rel'] == rel } )
    end

    # Add an object to the list
    def <<( obj )
      write_targets do |target|
        target.push({ 'rel' => rel_for_object( obj ), 'href' => id_for_object( obj ) })
      end
    end

    alias :push :<<
    alias :concat :<<

    # Replace a matching +rel+ with this object
    def replace( obj )
      delete( obj )

      self.<< obj
    end

    # Delete this object from the list
    def delete( obj )
      rel = rel_for_object( obj )

      write_targets do |target|
        target.reject! { |l| l['rel'] == rel }
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
      self
    end

    def rel_for_object( obj )
      c = @klass.correlation_for( obj )

      if c.nil? || obj.instance_of?( Hash )
        obj['rel']
      else
        c.rel
      end
    end

    def id_for_object( obj )
      c = @klass.correlation_for( obj )
      if c.nil? || obj.instance_of?( Hash )
        obj['href']
      else
        obj.send( c.id_method )
      end
    end

    def write_target
      @original_copy || @target_array
    end

    def write_targets( &block )
      yield @original_copy unless @original_copy.nil?

      yield @target_array
    end

    def method_missing( name, *args, &block )
      @target_array.send( name, *args, &block )
    end
  end
end
