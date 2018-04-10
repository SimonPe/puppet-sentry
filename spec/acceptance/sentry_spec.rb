require 'spec_helper_acceptance'

describe 'the sentry module' do
  context 'waiting for db connection' do
    it 'should connect to the db' do
      on :mysql, 'while ! mysql -u sentry -psentry -e ""&> /dev/null; do sleep 1; echo -n .; done'
    end
  end
  context 'a basic setup' do
    pp = <<-EOS
    class { 'python':
      virtualenv => 'present',
      dev        => 'present',
    }
    class { 'sentry':
      version        => '8.21.0',
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
  context 'an upgrade' do
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
    originalpid=''

    it 'applies with no errors' do
      originalpid = shell('cat /run/httpd/httpd.pid').stdout
      apply_manifest(pp, catch_failures: true)
    end
    it 'restarted apache' do
      shell('cat /run/httpd/httpd.pid') do |result|
        result.stdout.should_not eq(originalpid)
        originalpid = result.stdout
      end
    end
    it 'applies a second time without changes' do
      apply_manifest(pp, catch_changes: true)
    end
    it 'didn\'t restart apache' do
      shell('cat /run/httpd/httpd.pid') do |result|
        result.stdout.should eq(originalpid)
      end
    end
  end
end
