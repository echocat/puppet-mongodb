require 'spec_helper'

describe 'mongodb::mongod' , :type => :define do

  let(:title) { 'testdb' }

  context 'with defaults for all parameters on pre-systemd RedHat' do
    let(:facts) {{ :osfamily => 'redhat', :operatingsystemmajrelease => '6' }}
    let :pre_condition do
      'include ::mongodb::params'
    end    
    it { should contain_mongodb__mongod('testdb') }
    context 'with deactivate_transparent_hugepage set' do
      let(:params) {{ :mongod_deactivate_transparent_hugepage => true }}
      it { should contain_file("mongod_testdb_service").with_path("/etc/init.d/mongod_testdb").with_content(/\/sys\/kernel\/mm\/transparent_hugepage\//) }
    end
  end

  context 'with defaults for all parameters on pre-systemd Debian' do
    let(:facts) {{ :osfamily => 'debian', :lsbdistid => 'ubuntu', :operatingsystemmajrelease => '14.04' }}
    let :pre_condition do
      'include ::mongodb::params'
    end
    it { should contain_mongodb__mongod('testdb') }
    context 'with deactivate_transparent_hugepage set' do
      let(:params) {{ :mongod_deactivate_transparent_hugepage => true }}
      it { should contain_file("mongod_testdb_service").with_path("/etc/init.d/mongod_testdb").with_content(/\/sys\/kernel\/mm\/transparent_hugepage\//) }
    end
  end

  context 'with defaults for all parameters on Debian' do
    let(:facts) {{ :osfamily => 'debian', :lsbdistid => 'ubuntu', :operatingsystemmajrelease => '16.04' }}
    let :pre_condition do
      'include ::mongodb::params'
    end
    it { should contain_mongodb__mongod('testdb') }
    context 'with deactivate_transparent_hugepage set' do
      let(:params) {{ :mongod_deactivate_transparent_hugepage => true }}
      it { should contain_file("mongod_testdb_service").with_path("/lib/systemd/system/mongod_testdb.service").with_content(/\/sys\/kernel\/mm\/transparent_hugepage\//) }
    end
  end

end
