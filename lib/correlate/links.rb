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

      @delayed_writes = []
      @delayed_notifications = []
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
        if object.respond_to?( :new?  ) && object.new?
          @delayed_writes.push( object )
        else

          link = { 'rel' => rel_for_object( object ), 'href' => id_for_object( object ) }
          target.push( link ) unless target.include?( link )
        end
      end
    end

    alias :push :<<
    alias :concat :<<

    # Replace a matching +rel+ with this object, returns +self+
    def replace( obj )

      delete( obj )

      self.push obj
    end

    # Delete this object from the list, returns +self+
    def delete( object )

      write_targets do |target|
        rel = rel_for_object( object )
        target.reject! { |l| l['rel'] == rel }
      end

      if (c = @klass.correlation_for( object )) && c.recipocal?
        if self.owner && object.respond_to?( :links )
          if object.links.recipocal?( self.owner )
            object.links.delete( self.owner )
            object.save unless object.new? || @recipocating
          end
        end
      end

      self.owner.save if self.owner && !self.owner.new? && !@recipocating

      self
    end

    def respond_to?( *args )
      proxy_respond_to?( *args ) || @target_array.respond_to?( *args )
    end

    def recipocate_delayed_updates!
      @recipocating = true

      @delayed_writes.each do |obj|
        if obj.new?
          obj.links.notify( self.owner )
        else
          self.push( obj )
          obj.links.recipocate_delayed_updates!
          @delayed_writes.delete( obj )
        end
      end

      while obj = @delayed_notifications.pop
        obj.links.recipocate_delayed_updates!
      end

      @recipocating = false

      true # Don't halt any callback chains
    end

    def notify( target )
      @delayed_notifications.push target
    end

    def recipocal?( obj )
      rel = rel_for_object( obj )
      id = id_for_object( obj )

      any? { |link| link['rel'] == rel && link['href'] == id }
    end

    def __debug__
      {
        :object_id => object_id,
        :klass => @klass,
        :target_array => @target_array,
        :original_copy => @original_copy,
        :original_copy_object_id => @original_copy.object_id,
        :owner => owner,
        :delayed_write => @delayed_writes,
        :delayed_notifications => @delayed_notifications
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

    def write_targets

      yield @original_copy unless @original_copy.nil?
      yield @target_array
    end

    def write( object, &block )

      write_targets { |target| yield target, object }

      if (c = @klass.correlation_for( object )) && c.recipocal?
        if self.owner && object.respond_to?( :links )
          unless object.links.recipocal?( self.owner )
            c.type == :a ? object.links.replace( self.owner ) : object.links.push( self.owner )
            object.save unless object.new? || @recipocating
          end
        end
      end

      self.owner.save if self.owner && !self.owner.new? && !@recipocating

      self
    end

    def method_missing( name, *args, &block )
      @target_array.send( name, *args, &block )
    end
  end
end
