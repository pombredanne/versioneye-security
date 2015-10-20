class RubySecurityCrawler < CommonSecurity


  def self.logger
    ActiveSupport::Logger.new('log/ruby_security.log')
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
    url = "https://github.com/rubysec/ruby-advisory-db/tree/master/gems"
    page = Nokogiri::HTML(open(url))
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

    prod_key = yml['gem'].to_s.downcase
    title    = yml['title']

    sv              = fetch_sv prod_key, title
    sv.description  = yml['description']
    sv.framework    = yml['framework']
    sv.platform     = yml['platform']
    sv.cve          = yml['cve']
    sv.cvss_v2      = yml['cvss_v2']
    sv.osvdb        = yml['osvdb']
    sv.publish_date = yml['date']
    sv.links['URL'] = yml['url']
    sv.unaffected_versions_string = yml['unaffected_versions'].to_a.join('||')
    sv.patched_versions_string    = yml['patched_versions'].to_a.join('||')

    mark_affected_versions( sv )
    sv.save
  end


  def self.mark_affected_versions sv
    product = sv.product
    return nil if product.nil?

    unaffected_1 = VersionService.from_or_ranges product.versions, sv.unaffected_versions_string
    unaffected_2 = VersionService.from_or_ranges product.versions, sv.patched_versions_string

    affected_versions = []
    product.versions.each do |version|
      next if unaffected_1.to_a.include?(version) || unaffected_2.to_a.include?(version)
      affected_versions << version
    end

    mark_versions(sv, product, affected_versions)
  end


  def self.fetch_sv prod_key, title
    return nil if prod_key.to_s.empty? || title.to_s.empty?

    svs = SecurityVulnerability.by_language( Product::A_LANGUAGE_RUBY ).by_prod_key( prod_key )
    svs.each do |sv|
      next if sv.nil?
      return sv if sv.summary.to_s.eql?(title)
    end

    self.logger.info "Create new SecurityVulnerability for #{Product::A_LANGUAGE_RUBY}:#{prod_key} - #{title}"
    SecurityVulnerability.new(:language => Product::A_LANGUAGE_RUBY, :prod_key => prod_key, :summary => title )
  end

end
