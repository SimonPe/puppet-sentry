source "https://rubygems.org"

group :test do
  gem 'rake'
  gem 'puppet', ENV['PUPPET_GEM_VERSION'] || '~> 5.5.0'
  gem 'rspec'
  gem 'rspec-puppet'
  gem 'puppetlabs_spec_helper'
  gem 'metadata-json-lint'
  gem 'rspec-puppet-facts', '1.9.0'
  gem 'rubocop', '0.39.0'
  gem 'simplecov', '>= 0.11.0'
  gem 'simplecov-console'
  gem 'listen', '<= 3.0.6' # for older ruby support

  gem 'puppet-lint', '>= 2.3.0'
  gem 'puppet-lint-absolute_classname-check', '>= 0.2.0'
  gem 'puppet-lint-leading_zero-check', '>= 0.1.1'
  gem 'puppet-lint-trailing_comma-check', '>= 0.3.2'
  gem 'puppet-lint-version_comparison-check', '>= 0.2.1'
  gem 'puppet-lint-classes_and_types_beginning_with_digits-check', '>= 0.1.1'
  gem 'puppet-lint-unquoted_string-check', '>= 0.3.0'
  gem 'puppet-lint-resource_reference_syntax', '>= 1.0.10'

  gem 'parallel_tests'
end

group :development do
  gem 'travis'
  gem 'travis-lint'
  gem 'puppet-blacksmith'
  gem 'guard-rake'
  gem 'hiera-eyaml'
end

group :system_tests do
  # we need at least 3.9.0 for stretch support
  # we need 3.13.0 or earlier because of BKR-1111
  # 3.1 ~ 3.12  don't work on our ruby version.
  gem 'beaker', '~> 3.13.0'
  gem 'beaker-rspec'
  gem 'beaker-puppet_install_helper'
  gem 'beaker-module_install_helper'
  gem 'vagrant-wrapper'
end
