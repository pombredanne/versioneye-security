class JavaSecurityCrawler < CommonSecurity


  def self.logger
    ActiveSupport::Logger.new('log/java_security.log')
  end


  def self.crawl
    start_time = Time.now
    directories = self.get_first_level_list
    p "Found #{directories.count} directories to crawl."
    directories.each do |dir|
      self.crawl_directory dir
    end
    duration = Time.now - start_time
    dur = duration / 60
    self.logger.info(" *** This crawl took #{dur} minutes *** ")
    return nil
  end


  def self.get_first_level_list
    url = "https://github.com/victims/victims-cve-db/tree/master/database/java"
    page = Nokogiri::HTML( open(url) )
    page.xpath("//tbody/tr/td/span/a[@class='js-directory-link js-navigation-open']")
  end


  def self.crawl_directory dir
    return nil if dir.to_s.empty?

    href = dir['href']
    url = "https://github.com#{href}"
    page = Nokogiri::HTML(open(url))
    files = page.xpath("//tbody/tr/td/span/a[@class='js-directory-link js-navigation-open']")
    files.each do |file|
      crawl_file file
    end
  end


  def self.crawl_file node
    href = node['href']
    uri = href.gsub("blob/master", "master")
    abs_url = "https://raw.githubusercontent.com#{uri}"
    crawl_yml abs_url
  end


  def self.crawl_yml url
    self.logger.info "crawling #{url}"
    yml = Psych.load( open( url ) )
    yml['affected'].to_a.each do |affected|
      groupId    = affected['groupId']
      artifactId = affected['artifactId']
      prod_key   = "#{groupId}/#{artifactId}".downcase

      sv = fetch_sv Product::A_LANGUAGE_JAVA, prod_key, yml["cve"]
      update( sv, yml, affected )
      mark_affected_versions( sv, affected['version'] )
      sv.save
    end
  rescue => e
    self.logger.error "ERROR in crawl_yml Message: #{e.message}"
    self.logger.error e.backtrace.join("\n")
  end


  def self.update sv, yml, affected
    sv.description = yml['description']
    sv.summary     = yml['title']
    sv.cve         = yml['cve']
    sv.cvss_v2     = yml['cvss_v2']
    sv.affected_versions_string = affected['version'].to_a.join(" && ")
    sv.patched_versions_string  = affected['fixedin'].to_a.join(" && ")
    yml["references"].to_a.each do |reference|
      sv.links[reference] = reference if !sv.links.include?(reference)
    end
  end


  def self.mark_affected_versions sv, affected
    product = sv.product
    return nil if product.nil?

    affected_versions = []
    affected.each do |version_expr|
      if version_expr.match(/,/)
        sps    = version_expr.split(",")
        start  = sps[1]
        start  = "#{start}." if start.match(/-\z/).nil?
        subset = VersionService.versions_start_with( product.versions, start )
        affected_versions += VersionService.from_ranges( subset, version_expr )
        next
      end
      affected_versions += VersionService.from_ranges( product.versions, version_expr )
    end

    mark_versions( sv, product, affected_versions )
  end


end
