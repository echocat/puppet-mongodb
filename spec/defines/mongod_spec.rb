require 'spec_helper'

describe 'mongodb::mongod' , :type => :define do

  let(:title) { 'testdb' }

  context 'with defaults for all parameters on RedHat' do
    let(:facts) {{ :osfamily => 'RedHat' }}
    it { should contain_mongodb__mongod('testdb') }
    context 'with deactivate_transparent_hugepage set' do
      let(:params) {{ :mongod_deactivate_transparent_hugepage => true }}
      it { should contain_file("/etc/init.d/mongod_testdb").with_content(/\/sys\/kernel\/mm\/transparent_hugepage\//) }
    end
  end

  context 'with defaults for all parameters on Debian' do
    let(:facts) {{ :osfamily => 'Debian', :lsbdistid => 'ubuntu' }}
    it { should contain_mongodb__mongod('testdb') }
    context 'with deactivate_transparent_hugepage set' do
      let(:params) {{ :mongod_deactivate_transparent_hugepage => true }}
      it { should contain_file("/etc/init.d/mongod_testdb").with_content(/\/sys\/kernel\/mm\/transparent_hugepage\//) }
    end
    context 'with mongod_manage_service set to false' do
      let(:params) {{ :mongod_manage_service => false }}
      it {  should ! contain_service("mongod_testdb") }
    end
    context 'with mongod_manage_service unset' do
      it {  should contain_service("mongod_testdb") }
    end

  end

end
