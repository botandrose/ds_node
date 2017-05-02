require "spec_helper"
require "active_record"
require "database_cleaner"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
ActiveRecord::Migrator.migrate("db/migrate")

DatabaseCleaner.strategy = :transaction

RSpec.configure do |config|
  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

# silence deprecation warning
I18n.enforce_available_locales = true

