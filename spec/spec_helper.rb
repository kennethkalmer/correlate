$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'correlate'
require 'spec'
require 'spec/autorun'

require 'rubygems' unless ENV['NO_RUBYGEMS']
require 'couchrest'

unless defined?( COUCHHOST )
  COUCHHOST = "http://127.0.0.1:5984"
  TESTDB    = 'correlate-test'
  TEST_SERVER    = CouchRest.new
  TEST_SERVER.default_database = TESTDB
  DB = TEST_SERVER.database(TESTDB)
end

Spec::Runner.configure do |config|
  config.before(:all) { reset_test_db! }
end

def fixtures( *args )
  args.each do |file|
    file = file.to_s
    if File.exists?( File.join( File.dirname(__FILE__), 'fixtures', "#{file}.rb" ) )
      require File.join( File.dirname(__FILE__), 'fixtures', file )
    end
  end
end

def reset_test_db!
  DB.recreate! rescue nil
  DB
end
