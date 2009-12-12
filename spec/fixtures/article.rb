class Article < ActiveRecord::Base

  include Correlate

  related_to do
    some :comments, :class => 'Comment'
  end
end
