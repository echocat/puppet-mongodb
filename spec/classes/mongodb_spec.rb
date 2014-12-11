require 'spec_helper'
describe 'mongodb' do

  context 'with defaults for all parameters' do
    it { should contain_class('mongodb') }
  end
end
