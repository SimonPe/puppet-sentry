require 'spec_helper_acceptance'

describe 'the sentry module' do
  context 'a basic setup' do
    pp = <<-EOS
    class { 'python':
      virtualenv => 'present',
      dev        => 'present',
    }
    class { 'sentry':
      version        => '8.22.0',
      db_engine      => 'mysql',
      db_host        => 'mysql.sentry.example.org',
      db_name        => 'sentry',
      db_user        => 'sentry',
      db_password    => 'sentry',
      memcached_host => false,
      redis_host     => 'redis.sentry.example.org',
    }
    EOS
    it 'applies with no errors' do
      apply_manifest(pp, catch_failures: true)
    end
    it 'applies a second time without changes' do
      apply_manifest(pp, catch_changes: true)
    end
  end
end
