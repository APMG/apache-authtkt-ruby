require 'rubygems'
require 'rspec/autorun'
require "apache_auth_tkt"
require "json"

describe "A new AuthTkt" do
   it "should have sane defaults" do
      atkt = ApacheAuthTkt.new(:secret => 'fee-fi-fo-fum')
      #puts atkt.inspect
      atkt.ipaddr.should eql '0.0.0.0'
      atkt.digest_type.should eql 'md5'
      atkt.secret.should eql 'fee-fi-fo-fum'
   end

   it "should parse config for secret" do
      atkt = ApacheAuthTkt.new(:conf_file => 'test/test.conf')
      #puts atkt.inspect
      atkt.secret.should eql 'fee-fi-fo-fum'
   end

   it "should create ticket" do
      atkt = ApacheAuthTkt.new(:secret => 'fee-fi-fo-fum')
      tkt = atkt.create_ticket(:ts => 1000)
      tkt.should eql 'NDI5NTUwZWM0ZWM1MDJlMmZlOGUwNDhjMThlOWY4MDgwMDAwMDNlOGd1ZXN0ISE='
   end

   it "should create ticket with sha1" do
      atkt = ApacheAuthTkt.new(:secret => 'fee-fi-fo-fum', :digest_type => 'sha256')
      tkt = atkt.create_ticket(:ts => 1000)
      tkt.should eql 'ZWRmMzllMmM2NWFmNjljOWZlY2U1OTJmODE0OTQ2M2U0NzI1NThiMDE2YmFjMzRiMjMwM2UzM2FmNDM0MzYzYzAwMDAwM2U4Z3Vlc3QhIQ=='
   end

   it "should round-trip" do
      atkt = ApacheAuthTkt.new(:secret => 'fee-fi-fo-fum')
      tkt = atkt.create_ticket(:ts => 1000)
      #puts tkt.inspect
      parsed = atkt.validate_ticket(tkt)
      #puts atkt.error
      #puts parsed.inspect
      parsed[:user].should eql 'guest'
      parsed[:ts].should eql 1000
      parsed[:tokens].should eql ''
      parsed[:data].should eql ''
   end

   # json payload to test quotes bug
   it "should not strip quotes" do
      atkt = ApacheAuthTkt.new(:secret => 'fee-fi-fo-fum')
      tkt = atkt.create_ticket(:ts => 1000, :user_data => JSON.generate({ 'foo' => 'bar' }))
      parsed = atkt.validate_ticket(tkt)
      #puts parsed
      thawed = JSON.parse(parsed[:data])
      #puts thawed.inspect
   end
   
end
