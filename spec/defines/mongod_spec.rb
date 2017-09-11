require 'spec_helper'

describe 'mongodb::mongod' , :type => :define do

  let(:title) { 'testdb' }

  context 'with defaults for all parameters on pre-systemd RedHat' do
    let(:facts) {{ :osfamily => 'redhat', :operatingsystem => 'RedHat', :operatingsystemmajrelease => '6', :puppetversion => Puppet.version }}
    let :pre_condition do
      'include ::mongodb'
    end
    it { should contain_mongodb__mongod('testdb') }
    context 'with deactivate_transparent_hugepage set' do
      let(:params) {{ :mongod_deactivate_transparent_hugepage => true }}
      it { should contain_file("mongod_testdb_service").with_path("/etc/init.d/mongod_testdb").with_content(/\/sys\/kernel\/mm\/transparent_hugepage\//) }
    end
  end

  context 'with defaults for all parameters on pre-systemd Debian' do
    let(:facts) {{ :osfamily => 'debian', :operatingsystem => 'Ubuntu', :lsbdistid => 'ubuntu', :operatingsystemmajrelease => '14.04', :lsbdistrelease => '14.04', :puppetversion => Puppet.version }}
    let :pre_condition do
      'include ::mongodb'
    end
    it { should contain_mongodb__mongod('testdb') }
    context 'with deactivate_transparent_hugepage set' do
      let(:params) {{ :mongod_deactivate_transparent_hugepage => true }}
      it { should contain_file("mongod_testdb_service").with_path("/etc/init.d/mongod_testdb").with_content(/\/sys\/kernel\/mm\/transparent_hugepage\//) }
    end
    context 'with mongod_manage_service set to false' do
      let(:params) {{ :mongod_manage_service => false }}
      it {  should ! contain_service("mongod_testdb") }
    end
    context 'with mongod_manage_service unset' do
      it {  should contain_service("mongod_testdb") }
    end
  end

  context 'with defaults for all parameters on Debian' do
    let(:facts) {{ :osfamily => 'debian', :operatingsystem => 'Ubuntu', :lsbdistid => 'ubuntu', :operatingsystemmajrelease => '16.04', :lsbdistrelease => '16.04', :puppetversion => Puppet.version }}
    let :pre_condition do
      'include ::mongodb'
    end
    it { should contain_mongodb__mongod('testdb') }
    context 'with deactivate_transparent_hugepage set' do
      let(:params) {{ :mongod_deactivate_transparent_hugepage => true }}
      it { should contain_file("mongod_testdb_service").with_path("/lib/systemd/system/mongod_testdb.service").with_content(/\/sys\/kernel\/mm\/transparent_hugepage\//) }
    end
  end

end
