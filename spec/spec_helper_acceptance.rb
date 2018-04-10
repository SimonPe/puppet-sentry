require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

add_role_def('puppetised')
run_puppet_install_helper_on([puppetised], 'agent') unless ENV['BEAKER_provision'] == 'no'

RSpec.configure do |c|
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    install_dev_puppet_module_on([puppetised], :source => module_root, :module_name => 'sentry', :target_module_path => '/etc/puppetlabs/code/modules')
    install_module_dependencies_on([puppetised])
  end
end
