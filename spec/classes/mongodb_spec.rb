require 'spec_helper'

describe 'mongodb' do

  context 'Unsupported OS' do
    let(:facts) {{ :osfamily => 'unsupported' }}
    it { expect { should contain_class('mongodb')}.to raise_error(Puppet::Error, /Unsupported OS/ )}
  end

  context 'with defaults for all parameters on RedHat' do
    let(:facts) {{ :osfamily => 'RedHat' }}
    it { should contain_class('mongodb') }
  end

  context 'with defaults for all parameters on Debian' do
    let(:facts) {{ :osfamily => 'Debian', :lsbdistid => 'ubuntu' }}
    it { should contain_class('mongodb') }
  end

end
