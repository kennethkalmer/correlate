module Correlate
  module Relationships
    class ActiveRecord
      class CollectionProxy

        instance_methods.each { |m| undef_method m unless m =~ /(^__|^send$|^object_id$)/ }

        def initialize( source, correlation )
          @source = source
          @correlation = correlation
          @collection = correlation.correlate( source )
        end

        def <<( object )
          correlation = @correlation.opposite

          object.send( "#{correlation.name}=", @source )
          object.save
        end

        protected

        def method_missing( name, *args, &block )
          @collection.send( name, *args, &block )
        end
      end
    end
  end
end
