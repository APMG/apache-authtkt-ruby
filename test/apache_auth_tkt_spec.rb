require 'rubygems'
require 'rspec/autorun'
require "apache_auth_tkt"

describe "A new AuthTkt" do
   it "should have sane defaults" do
      atkt = ApacheAuthTkt.new({:secret => 'fee-fi-fo-fum'})
      #puts atkt.inspect
      atkt.ipaddr.should eql '0.0.0.0'
      atkt.digest_type.should eql 'md5'
      atkt.secret.should eql 'fee-fi-fo-fum'
   end

   it "should parse config for secret" do
      atkt = ApacheAuthTkt.new({:conf_file => 'test/test.conf'})
      #puts atkt.inspect
      atkt.secret.should eql 'fee-fi-fo-fum'
   end

   it "should create ticket" do
      atkt = ApacheAuthTkt.new({:secret => 'fee-fi-fo-fum'})
      tkt = atkt.create_ticket(:timestamp => 1000)
      tkt.should eql 'NDI5NTUwZWM0ZWM1MDJlMmZlOGUwNDhjMThlOWY4MDgwMDAwMDNlOGd1ZXN0ISE='
   end
end
