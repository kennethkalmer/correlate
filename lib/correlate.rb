
module Correlate

  autoload :Relationships, 'correlate/relationships'
  autoload :Links,         'correlate/links'
  autoload :Correlation,   'correlate/correlation'

  def self.included( base )
    base.extend( ClassMethods )
  end

  module ClassMethods

    def related_to( &block )
      Correlate::Relationships.configure!( self, &block )
    end

    def links=( array )
      Correlate::Links.new( self, array )
    end

    def correlations
      @correlations ||= []
    end

  end

end
