apache-authtkt-ruby
===================

Ruby client for mod_auth_tkt (http://www.openfusion.com.au/labs/mod_auth_tkt/).

Inspired by http://meso.net/mod_auth_tkt yet implemented as a full class with
test coverage.

Inspired by https://github.com/yabawock/devise_ticketable yet fully configurable.

Mostly a clean port from the Apache_AuthTkt implementation at
https://github.com/publicinsightnetwork/audience-insight-repository/blob/master/lib/shared/Apache_AuthTkt.php

Example usage:

    require "apache_authtkt"
    atkt = ApacheAuthTkt.new(secret: 'fee-fi-fo-fum')
    # create a ticket to set as a cookie
    tkt = atkt.create_ticket(
           user: 'myusername',
           tokens: 'foo,bar,baz',
           user_data: 'some payload'
    )

    # validate an existing cookie ticket
    if (validated = atkt.validate_ticket(tkt))
        puts 'user ' + validated[:user] + ' is authenticated'
    end

Licensed under Apache License 2.0.
