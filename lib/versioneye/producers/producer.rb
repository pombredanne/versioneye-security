class Producer

  require 'bunny'

  def get_connection
    connection_url = "amqp://#{Settings.instance.rabbitmq_addr}:#{Settings.instance.rabbitmq_port}"
    Bunny.new( connection_url )
  end

  def log
    Versioneye::Log.instance.log
  end

end
