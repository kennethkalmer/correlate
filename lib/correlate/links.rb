module Correlate
  # Thin proxy around the array of links.
  class Links

    alias :proxy_respond_to? :respond_to?
    instance_methods.each { |m| undef_method m unless m =~ /(^__|^send$|^proxy_|^object_id$)/ }

    attr_accessor :owner

    def initialize( klass, array = [], owner = nil )
      @klass = klass
      @target_array = array
      @owner = owner
    end

    # Extract all the matching links for rel.
    #
    # @param [String] rel
    # @return [ Correlate::Links ] for matching links
    def rel( rel )
      clone( @target_array.select { |link| link['rel'] == rel } )
    end

    # Add an object to the list, returns +self+
    def <<( obj )

      write( obj ) do |target, object|
        target.push({ 'rel' => rel_for_object( object ), 'href' => id_for_object( object ) })
      end
    end

    alias :push :<<
    alias :concat :<<

    # Replace a matching +rel+ with this object, returns +self+
    def replace( obj )

      delete( obj )

      self.push obj

      self
    end

    # Delete this object from the list, returns +self+
    def delete( obj )

      write( obj ) do |target|
        rel = rel_for_object( obj )
        target.reject! { |l| l['rel'] == rel }
      end
    end

    def respond_to?( *args )
      proxy_respond_to?( *args ) || @target_array.respond_to?( *args )
    end

    def __debug__
      {
        :object_id => object_id,
        :klass => @klass,
        :target_array => @target_array,
        :original_copy => @original_copy,
        :original_copy_object_id => @original_copy.object_id,
        :owner => owner
      }
    end

    protected

    def clone( array )
      copy = Links.new( @klass, array )
      copy.subset_of( @original_copy || self )
      copy.owner = self.owner
      copy
    end

    def subset_of( links_instance )
      @original_copy = links_instance
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

    def write( object, &block )
      yield @original_copy, object unless @original_copy.nil?

      yield @target_array, object

      if (c = @klass.correlation_for( object )) && c.recipocal?
        if self.owner && object.respond_to?( :links )
          yield object.links, self.owner
          object.save
        end
      end

      self.owner.save if self.owner

      self
    end

    def method_missing( name, *args, &block )
      @target_array.send( name, *args, &block )
    end
  end
end
