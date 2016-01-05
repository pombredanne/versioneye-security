class Worker

  require 'bunny'

  def get_connection
    Bunny.new("amqp://#{Settings.instance.rabbitmq_addr}:#{Settings.instance.rabbitmq_port}")
  end

  def self.log
    if !defined?(@@log) || @@log.nil?
      @@log = Versioneye::DynLog.new("log/worker.log", 10).log
    end
    @@log
  end

  def log
    Worker.log
  end

end
