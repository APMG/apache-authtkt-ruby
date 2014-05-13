require 'spec_helper'

describe ApacheAuthTkt do
   it "should have sane defaults" do
      atkt = ApacheAuthTkt.new(:secret => 'fee-fi-fo-fum')
      #puts atkt.inspect
      atkt.ipaddr.should eql '0.0.0.0'
      atkt.digest_type.should eql 'md5'
      atkt.secret.should eql 'fee-fi-fo-fum'
   end

   it "should parse config for secret" do
      atkt = ApacheAuthTkt.new(:conf_file => 'spec/fixtures/test.conf')
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

   describe '#expired?' do
      it 'should return false for recent tickets' do
         atkt = ApacheAuthTkt.new(secret: 'fee-fi-fo-fum')
         tkt = atkt.create_ticket

         expect(atkt.expired?(tkt)).to be_false
      end

      it 'should return true for old tickets' do
         atkt = ApacheAuthTkt.new(secret: 'fee-fi-fo-fum')
         tkt = atkt.create_ticket(ts: 1000)
         expect(tkt).to eql 'NDI5NTUwZWM0ZWM1MDJlMmZlOGUwNDhjMThlOWY4MDgwMDAwMDNlOGd1ZXN0ISE='

         expect(atkt.expired?(tkt)).to be_true
      end

      it 'should return true for old tickets given arbitrary lifetimes' do
         atkt = ApacheAuthTkt.new(secret: 'fee-fi-fo-fum', lifetime: 30000)
         tkt = atkt.create_ticket(ts: Time.now.to_i-30002)

         expect(atkt.expired?(tkt)).to be_true
      end

      it 'should return false for new tickets given arbitrary lifetimes' do
         atkt = ApacheAuthTkt.new(secret: 'fee-fi-fo-fum', lifetime: 30000)
         tkt = atkt.create_ticket(ts: Time.now.to_i-29990)

         expect(atkt.expired?(tkt)).to be_false
      end

      it 'should return false for all tickets when nil' do
         atkt = ApacheAuthTkt.new(secret: 'fee-fi-fo-fum', lifetime: nil)
         tkt = atkt.create_ticket(ts: Time.now.to_i-29990)

         expect(atkt.expired?(tkt)).to be_false
      end
   end

end
