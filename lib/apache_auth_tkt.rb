# ApacheAuthTkt is a Ruby client
# for mod_auth_tkt (http://www.openfusion.com.au/labs/mod_auth_tkt/)
#
# Copyright 2014 American Public Media Group
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# dependencies
require 'rubygems'
require 'base64'

class ApacheAuthTkt

   attr_accessor :secret
   attr_accessor :ipaddr
   attr_accessor :digest_type
   attr_accessor :conf_file
   attr_accessor :error
   attr_accessor :base64encode

   def initialize(args)

      #puts args.inspect

      # set defaults
      if (args.has_key? :ipaddr)
         @ipaddr = args[:ipaddr]
      else
         @ipaddr = '0.0.0.0'
      end

      if (args.has_key? :secret)
         @secret = args[:secret]
      elsif (args.has_key? :conf_file)
         @secret = _get_secret(args[:conf_file])
         if (!@secret.length)
            raise "Can't parse secret from " + args[:conf_file]
         end
      else
         raise "Must pass 'secret' or 'conf_file'"
      end

      if (args[:digest_type])
         @digest_type = args[:digest_type]
      else
         @digest_type = 'md5'
      end

      if (args.has_key? :base64encode)
         @base64encode = args[:base64encode]
      else
         @base64encode = true
      end


   end

   def _get_secret(filename)
      # based on http://meso.net/mod_auth_tkt
      if (!File.file? filename)
         raise "#{filename} is not a file"
      end
      secret_str = ''
      open(filename) do |file|
         file.each do |line|
            if line.include? 'TKTAuthSecret'
               secret_str = line.gsub('TKTAuthSecret', '').strip.gsub("\"", '').gsub("'",'')
               break
            end
         end
      end
      return secret_str
   end

   # from http://meso.net/mod_auth_tkt
   # function adapted according to php: generates an IPv4 Internet network address
   # from its Internet standard format (dotted string) representation.
   def ip2long(ip)
      long = 0
      ip.split( /\./ ).reverse.each_with_index do |x, i|
         long += x.to_i << ( i * 8 )
      end
      long
   end

   # based on http://meso.net/mod_auth_tkt
   def create_ticket(user_opts={})
      options = {
         :user       => 'guest',
         :tokens     => '',
         :user_data  => '',
         :ignore_ip  => false,
         :timestamp  => Time.now.to_i
      }.merge(user_opts)

      timestamp  = options[:timestamp]
      ip_address = options[:ignore_ip] ? '0.0.0.0' : @ipaddr
      digest = get_digest(timestamp, ip_address, options[:user], options[:tokens], options[:user_data])
      tkt = sprintf("%s%08x%s!%s!%s", digest, timestamp, options[:user], options[:tokens], options[:user_data])

      if (@base64encode)
         tkt = Base64.encode64(tkt).gsub("\n", '').strip
      end

      return tkt

   end

   def get_digest(ts, ipaddr, uid, tokens, data)
      ipts = [ip2long(ipaddr), ts].pack("NN")
      digest0 = nil
      digest  = nil
      raw     = ipts + @secret + uid + "\0" + tokens + "\0" + data
      if (@digest_type == 'md5')
         digest0 = Digest::MD5.hexdigest(raw)
         digest  = Digest::MD5.hexdigest(digest0 + @secret)
      elsif (@digest_type == 'sha1')
         # TODO
      end
      return digest
   end

   def validate_ticket(tkt, ipaddr='0.0.0.0')


   end

   def parse_ticket(tkt)


   end

end
