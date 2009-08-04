# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sentry}
  s.version = "0.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["John Pelly", "David Stevenson"]
  s.date = %q{2009-07-30}
  s.description = %q{Asymmetric encryption of active record fields}
  s.email = %q{commoncode@pivotallabs.com}
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    ".gitignore",
     "CHANGELOG",
     "MIT-LICENSE",
     "README",
     "RUNNING_UNIT_TESTS",
     "Rakefile",
     "VERSION",
     "init.rb",
     "lib/active_record/sentry.rb",
     "lib/sentry.rb",
     "lib/sentry/asymmetric_sentry.rb",
     "lib/sentry/asymmetric_sentry_callback.rb",
     "lib/sentry/sha_sentry.rb",
     "lib/sentry/symmetric_sentry.rb",
     "lib/sentry/symmetric_sentry_callback.rb",
     "sentry.gemspec",
     "tasks/sentry.rake",
     "test/abstract_unit.rb",
     "test/asymmetric_sentry_callback_test.rb",
     "test/asymmetric_sentry_test.rb",
     "test/database.yml",
     "test/fixtures/user.rb",
     "test/fixtures/users.yml",
     "test/keys/encrypted_private",
     "test/keys/encrypted_public",
     "test/keys/private",
     "test/keys/public",
     "test/schema.rb",
     "test/sha_sentry_test.rb",
     "test/symmetric_sentry_callback_test.rb",
     "test/symmetric_sentry_test.rb",
     "test/tests.rb"
  ]
  s.homepage = %q{http://github.com/pivotal/sentry}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Asymmetric encryption of active record fields}
  s.test_files = [
    "test/abstract_unit.rb",
     "test/asymmetric_sentry_callback_test.rb",
     "test/asymmetric_sentry_test.rb",
     "test/fixtures/user.rb",
     "test/schema.rb",
     "test/sha_sentry_test.rb",
     "test/symmetric_sentry_callback_test.rb",
     "test/symmetric_sentry_test.rb",
     "test/tests.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
