# frozen_string_literal: true

title 'sqldeveloper archives profile'

control 'sqldeveloper archive' do
  impact 1.0
  title 'should be installed'

  describe file('/etc/default/sqldeveloper.sh') do
    it { should exist }
  end
  # describe file('/usr/local/oracle/sqldeveloper-*/bin/sqldeveloper') do
  #   it { should exist }
  # end
  describe file('/usr/share/applications/sqldeveloper.desktop') do
    it { should exist }
  end
  describe file('/usr/local/bin/sqldeveloper') do
    it { should exist }
  end
end
