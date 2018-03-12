require 'spec_helper'

describe ApacheAuthTkt do
  it 'should have sane defaults' do
    atkt = ApacheAuthTkt.new(secret: 'fee-fi-fo-fum')
    expect(atkt.ipaddr).to eql '0.0.0.0'
    expect(atkt.digest_type).to eql 'md5'
    expect(atkt.secret).to eql 'fee-fi-fo-fum'
  end

  it 'should parse config for secret' do
    atkt = ApacheAuthTkt.new(conf_file: 'spec/fixtures/test.conf')
    expect(atkt.secret).to eql 'fee-fi-fo-fum'
  end

  it 'should create ticket' do
    atkt = ApacheAuthTkt.new(secret: 'fee-fi-fo-fum')
    tkt = atkt.create_ticket(ts: 1000)
    expect(tkt).to eql 'NDI5NTUwZWM0ZWM1MDJlMmZlOGUwNDhjMThlOWY4MDgwMDAwMDNlOGd1ZXN0ISE='
  end

  it 'should create ticket with sha256' do
    atkt = ApacheAuthTkt.new(secret: 'fee-fi-fo-fum', digest_type: 'sha256')
    tkt = atkt.create_ticket(ts: 1000)
    expect(tkt).to eql 'ZWRmMzllMmM2NWFmNjljOWZlY2U1OTJmODE0OTQ2M2U0NzI1NThiMDE2YmFjMzRiMjMwM2UzM2FmNDM0MzYzYzAwMDAwM2U4Z3Vlc3QhIQ=='
  end

  describe 'digest types' do
    ['Md5', 'sHA256', 'SHa512'].each do |digest_type|
      it "should round-trip #{digest_type}" do
        atkt = ApacheAuthTkt.new(secret: 'fee-fi-fo-fum', digest_type: digest_type)
        tkt = atkt.create_ticket(ts: 1000)
        parsed = atkt.validate_ticket(tkt)
        expect(parsed[:user]).to eql 'guest'
        expect(parsed[:ts]).to eql 1000
        expect(parsed[:tokens]).to eql ''
        expect(parsed[:data]).to eql ''
      end
    end
  end

  # json payload to test quotes bug
  it 'should not strip quotes' do
    atkt = ApacheAuthTkt.new(secret: 'fee-fi-fo-fum')
    tkt = atkt.create_ticket(ts: 1000, user_data: JSON.generate('foo' => 'bar'))
    parsed = atkt.validate_ticket(tkt)
    thawed = JSON.parse(parsed[:data])
    expect(thawed).to_not be_nil
  end

  describe '#expired?' do
    it 'should return false for recent tickets' do
      atkt = ApacheAuthTkt.new(secret: 'fee-fi-fo-fum')
      tkt = atkt.create_ticket

      expect(atkt.expired?(tkt)).to eql false
    end

    it 'should return true for old tickets' do
      atkt = ApacheAuthTkt.new(secret: 'fee-fi-fo-fum')
      tkt = atkt.create_ticket(ts: 1000)
      expect(tkt).to eql 'NDI5NTUwZWM0ZWM1MDJlMmZlOGUwNDhjMThlOWY4MDgwMDAwMDNlOGd1ZXN0ISE='

      expect(atkt.expired?(tkt)).to eql true
    end

    it 'should return true for old tickets given arbitrary lifetimes' do
      atkt = ApacheAuthTkt.new(secret: 'fee-fi-fo-fum', lifetime: 30_000)
      tkt = atkt.create_ticket(ts: Time.now.to_i - 30_002)

      expect(atkt.expired?(tkt)).to eql true
    end

    it 'should return false for new tickets given arbitrary lifetimes' do
      atkt = ApacheAuthTkt.new(secret: 'fee-fi-fo-fum', lifetime: 30_000)
      tkt = atkt.create_ticket(ts: Time.now.to_i - 29_990)

      expect(atkt.expired?(tkt)).to eql false
    end

    it 'should return false for all tickets when nil' do
      atkt = ApacheAuthTkt.new(secret: 'fee-fi-fo-fum', lifetime: nil)
      tkt = atkt.create_ticket(ts: Time.now.to_i - 29_990)

      expect(atkt.expired?(tkt)).to eql false
    end
  end
end
