#! /usr/bin/ruby

Puppet::Type.newtype(:start_detector) do
  @doc = %q{Wait while sending queries to every
    servers defined in recipe until all (or at
    least one of them) send an answer

    Set a timeout in case of unavailability

    timeout (integer): number of times where it will try to join the servers
    servers (string|array): servers to join, can be:
      - string delimited by commas: "server1.example.com,server2.example"
      - array: ["server1.example.com", "server2.example"]
    policy (string): can only take two values:
      - all (default): all servers must be reached
      - one : one of them is sufficient

    Example:

      start_detector { 'servers_to_join':
        timeout => 120
        config_servers => [
          'server1.example.com:24018',
          'server2.example.com:24018',
          'server3.example.com:24018',
        ],
        policy => all
      }
  }

  ensurable

  newparam(:name, :namevar => true) do
    validate do |value|
      unless value =~ /^\w+/
        raise ArgumentError, "%s should be a string" % value
      end
    end
  end

  newparam(:timeout) do
    validate do |value|
      unless value =~ /^\d+/ or value
        raise ArgumentError, "%s should be a number" % value
      end
    end
  end

  newparam(:policy) do
    defaultto :all
    newvalues(:one, :all)
  end

  newparam(:servers, :array_matching => :all) do
    validate do |values|
      Array(values).each do |value|
        unless value =~ /[\w\-\.]+:\d+,*/
          raise ArgumentError, "%s should respect pattern hostname:port" % value
        end
      end
    end
  end
end
