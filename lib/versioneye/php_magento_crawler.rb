class PhpMagentoCrawler < PhpSensiolabsCrawler


  A_GIT_DB = "https://github.com/Cotya/magento-security-advisories.git"


  def self.logger
    ActiveSupport::Logger.new('log/php_magento_security.log')
  end


  def self.crawl
    meassure_exec{ perform_crawl }
  end


  def self.perform_crawl
    db_dir = '/tmp/magento-security-advisories'

    `(cd /tmp && git clone #{A_GIT_DB})`
    `(cd #{db_dir} && git pull)`

    i = 0
    logger.info "start reading yaml files"
    all_yaml_files( db_dir ) do |filepath|
      i += 1
      logger.info "##{i} parse yaml: #{filepath}"
      parse_yaml filepath
    end
  end


end
