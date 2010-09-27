require 'rubygems'
require 'eventmachine'
require 'yaml'
require 'rush'
require 'logger'


class RushServer < EM::Connection
  attr_accessor :data, :log, :box, :config, :protocol
  def initialize *args
    @data = nil
    @log = Logger::new("./rushd.log")
    @log.level = Logger::DEBUG
    @data = @data ? @data : []
    @protocol = 'rushmore'
    super
    @log.warn "#{self} initialize done"
    @log.debug("Data: #{@data}")
  end
  
  def receive_data(data)
    @log.debug("Data : #{data}")
    close_connection if data =~ /quit/i
    begin
      if data =~ /protocol/i
        send_data @protocol
      else
        params = YAML.load(data)
        result = box.connection.receive(params)
        @log.debug("result : #{result}")
        send_data result
      end
      close_connection_after_writing
    rescue Rush::Exception => e
      @log.error('exception on cmd #{e}')
      close_connection
    end
  end
  def box
   	@box ||= Rush::Box.new('localhost')
  end

  def config
   @config ||= Rush::Config.new
  end

end

