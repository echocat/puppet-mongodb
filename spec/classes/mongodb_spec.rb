require 'spec_helper'

describe 'mongodb', :type => 'class' do

  context 'Unsupported OS' do
    let(:facts) {{ :osfamily => 'unsupported', :operatingsystem => 'UnknownOS' }}
    it { is_expected.to raise_error(Puppet::Error,/Unsupported OS/ )}
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let :pre_condition do 
        'include ::mongodb' 
      end

      case facts[:osfamily]
      when 'Debian' then
        it { should contain_class('mongodb') }        
      when 'RedHat' then
        it { should contain_class('mongodb') }       
      else
        it { is_expected.to raise_error(Puppet::Error,/Unsupported OS/ )}
      end
    end
  end
end
