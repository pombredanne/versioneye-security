class SecurityWorker < Worker


  def work
    connection = get_connection
    connection.start
    channel = connection.create_channel
    queue   = channel.queue("security_crawl", :durable => true)

    multi_log " [*] Waiting for messages in #{queue.name}. To exit press CTRL+C"

    begin
      queue.subscribe(:ack => true, :block => true) do |delivery_info, properties, message|

        multi_log " [x] Received #{message}"
        process_work message
        multi_log "   - Job done for #{message}"

        channel.ack(delivery_info.delivery_tag)
      end
    rescue => e
      log.error e.message
      log.error e.backtrace.join("\n")
      connection.close
    end
  end


  def process_work message
    return nil if message.to_s.empty?

    if message.eql?("node_security")
      NodeSecurityCrawler.crawl
    elsif message.eql?('php_sensiolabs')
      PhpSensiolabsCrawler.crawl
    elsif message.eql?('php_magento')
      PhpMagentoCrawler.crawl
    elsif message.eql?('ruby_security')
      RubySecurityCrawler.crawl
    elsif message.eql?('java_security')
      JavaSecurityCrawler.crawl
    elsif message.eql?('python_security')
      PythonSecurityCrawler.crawl
    end
  rescue => e
    log.error e.message
    log.error e.backtrace.join("\n")
  end


  private


    def multi_log log_msg
      puts log_msg
      log.info log_msg
    end


end
