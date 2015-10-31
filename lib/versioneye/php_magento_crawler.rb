class PhpMagentoCrawler < CommonSecurity


  A_GIT_DB = "https://github.com/Cotya/magento-security-advisories.git"


  def self.logger
    ActiveSupport::Logger.new('log/php_magento_security.log')
  end


  def self.crawl
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


  def self.all_yaml_files(dir, &block)
    Dir.glob "#{dir}/**/*.yaml" do |filepath|
      block.call filepath
    end
  rescue => e
    logger.error e.message
    logger.error e.backtrace.join("\n")
  end


  def self.parse_yaml filepath
    yml = Psych.load_file( filepath )

    reference = yml['reference'].to_s
    prod_key  = reference.gsub("composer://", "").downcase
    name_id   = filepath.split("/").last.gsub(".yaml", "").gsub(".yml", "")

    sv = fetch_sv Product::A_LANGUAGE_PHP, prod_key, name_id
    sv.cve = yml['cve']
    sv.summary = yml['title']
    sv.links['link'] = yml['link']
    sv.affected_versions_string = ''
    yml['branches'].each do |branch|
      branch.each do |bran|
        next if bran['versions'].to_s.empty?
        bran['versions'].to_a.each do |version_range|
          sv.affected_versions_string += "[#{version_range}]"
          sv.publish_date = bran['time']
        end
      end
    end

    mark_affected_versions( sv )
    sv.save
  rescue => e
    self.logger.error e.message
    self.logger.error e.backtrace.join("\n")
  end


  def self.mark_affected_versions sv
    product = sv.product
    return nil if product.nil?

    matches = sv.affected_versions_string.scan(/\[(.*?)\]/xi)
    matches.each do |version_range|
      versions = VersionService.from_ranges product.versions, version_range.first
      mark_versions(sv, product, versions)
    end
  end


end
