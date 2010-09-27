#
require 'rubygems' if RUBY_VERSION =~ /1.8/
require 'eventmachine'
require 'logger'
module Rushd
  
  
  
  DEFAULTS = {
      :address => '127.0.0.1',
      :port => Rush::Config::DefaultPort,
      :log_file => '/tmp/rush.log'
    }
  class << self

     attr_accessor *DEFAULTS.keys


     
     def configure(config = {}, &block)
       block_given? ? yield(self) :
         config.each{|name, val| send(:"#{name}=", val) }
     end
     def config
       DEFAULTS.keys.inject({}) do |memo, name|
         memo.merge(name => send(name))
       end
     end
     
     def process(data)
        Client.get(data)
      end
     
  module Client 
      #
      # Initialize the client connection.
      #
  
      class << self
           def get(data)
             EventMachine::run do
               EventMachine::connect(Rushd.address, Rushd.port, EM) {|conn|
                 @result = conn.send_data(data)
                 puts "#{conn} sent #{line}"
                }
                
             end
             @result
           end
      end
     
  end
end