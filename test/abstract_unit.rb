$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'test/unit'
require 'active_record'
require 'active_record/fixtures'
require 'active_support/test_case'
#require 'active_support/binding_of_caller'
#require 'active_support/breakpoint'
require "#{File.dirname(__FILE__)}/../lib/sentry"

config_location = File.dirname(__FILE__) + '/database.yml'

config = YAML::load(IO.read(config_location))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'mysql'])
ActiveRecord::Base.configurations["test"] = "lolcatz"

load(File.dirname(__FILE__) + "/schema.rb")

class ActiveSupport::TestCase #:nodoc:
  include ActiveRecord::TestFixtures
  #def create_fixtures(*table_names)
  #  if block_given?
  #    Fixtures.create_fixtures(ActiveSupport::TestCase.fixture_path, table_names) { yield }
  #  else
  #    Fixtures.create_fixtures(ActiveSupport::TestCase.fixture_path, table_names)
  #  end
  #end

  self.use_instantiated_fixtures  = false
  self.use_transactional_fixtures = true
end

def create_fixtures(*table_names, &block)
  Fixtures.create_fixtures(ActiveSupport::TestCase.fixture_path, table_names, {}, &block)
end



ActiveSupport::TestCase.fixture_path = File.dirname(__FILE__) + "/fixtures/"
ActiveSupport::TestCase.use_instantiated_fixtures = true
ActiveSupport::TestCase.use_transactional_fixtures = (ENV['AR_TX_FIXTURES'] == "yes")
$LOAD_PATH.unshift(ActiveSupport::TestCase.fixture_path)