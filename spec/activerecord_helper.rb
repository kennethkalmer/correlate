require 'activerecord'

# Setup connection
def reset_test_sqlitedb!
  ActiveRecord::Base.connection.disconnect! rescue nil
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => ':memory:'
  )

  ActiveRecord::Schema.verbose = false
  ActiveRecord::Schema.define do
    create_table :articles do |t|
      t.string 'title'
    end
  end
end
