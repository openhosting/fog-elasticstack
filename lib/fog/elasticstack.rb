require 'faraday'
require 'patron'
require 'json'
require 'thread'
Dir[File.dirname(__FILE__) + '/*.rb'].each do |file|
  require file
end

module Fog
  module ElasticStack
    VERSION = "0.0.3"

    class << self
      attr_accessor :connection, :debian, :foo

      def initialize
        @connection = ESConnection.connect
        @lock = Mutex.new
      end

      def connection
        return @connection
      end

      def foo
        puts "bar"
      end

      def debian(conn=@connection)

        drive = ""
        @lock.synchronize {
          drive = self.debian_drive(@connection)
        }

        @lock.synchronize {
          self.debian_server(@connection, drive)
        }
      end

      def debian_server(conn=@connection, drive)
        s = ESServers.new(conn)
        pw = (0...8).map { (65 + rand(26)).chr }.join
        server = ESServer.new("Debian",500,256,{"nic:0:dhcp" => "auto", "vnc" => "auto", "password" => pw, "ide:0:0" => drive, "boot" => "ide:0:0" })
        sid = s.create(server)
      end

      def debian_drive(conn=@connection)
        d = ESDrives.new(conn)
        drive = ESDrive.new("Debian", "2G")
        did = d.create(drive)
        d.image(did['drive'], DEBIAN[:wheezy])
        return did['drive']
      end
    end
  end
end