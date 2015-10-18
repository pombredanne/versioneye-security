class NodeSecurityCrawler < CommonSecurity


  def self.logger
    ActiveSupport::Logger.new('log/node_security.log')
  end


  def self.crawl
    start_time = Time.now
    nodes = self.get_first_level_list
    p "Found #{nodes.count} elements to crawl."
    nodes.each do |node|
      self.crawle_package node
    end
    duration = Time.now - start_time
    self.logger.info(" *** This crawl took #{duration} *** ")
    return nil
  end


  def self.get_first_level_list
    url = "https://github.com/nodesecurity/nodesecurity-www/tree/master/advisories"
    page = Nokogiri::HTML(open(url))
    page.xpath("//tbody/tr/td/span/a[@class='js-directory-link js-navigation-open']")
  end


  def self.crawle_package li_node
    return nil if li_node.to_s.empty?

    href = li_node['href']
    uri = href.gsub("blob/master", "master")
    abs_url = "https://raw.githubusercontent.com#{uri}"
    self.logger.info "crawling #{abs_url}"
    response = HttpService.fetch_response abs_url
    process_file response.body
  rescue => e
    self.logger.error "ERROR in crawle_package Message: #{e.message}"
    self.logger.error e.backtrace.join("\n")
  end


  def self.process_file content
    content_hash = parse content
    prod_key     = content_hash[:module_name]
    title        = content_hash[:title]

    sv                          = fetch_sv prod_key, title
    sv.author                   = content_hash[:author]
    sv.publish_date             = content_hash[:publish_date]
    sv.affected_versions_string = content_hash[:vulnerable_versions]
    sv.patched_versions_string  = content_hash[:patched_versions]
    sv.description_md           = content_hash[:description]

    parse_cve( sv, content_hash )
    mark_affected_versions( sv )
    sv.save
  end


  def self.parse_cve sv, content_hash
    cve_array = eval(content_hash[:cves])
    cve_array = eval( cve_array )
    return nil if cve_array.nil? || cve_array.empty?

    cve_array.each do |element|
      name = element[:name]
      link = element[:link]
      next if name.to_s.empty? || link.to_s.empty?

      sv.links[name] = link
      sv.cve = name
    end
  rescue => e
    self.logger.error "ERROR in parse_cve Message: #{e.message}"
    self.logger.error e.backtrace.join("\n")
  end


  def self.mark_affected_versions sv
    product = sv.product
    return nil if product.nil?

    versions = VersionService.from_or_ranges product.versions, sv.affected_versions_string
    mark_versions(sv, product, versions)
  end


  def self.parse content
    md_content = false
    resp = {}
    lines = content.split("\n")
    lines.each do |line|
      if line.match(/\A\.\.\./)
        md_content = true
        resp[:description] = ''
        next
      end
      if md_content
        resp[:description] += "#{line}\n"
        next
      end
      if line.match(/\Aauthor\:/)
        resp[:author] = line.gsub(/\Aauthor\:/, "").strip
      elsif line.match(/\Atitle\:/)
        resp[:title] = line.gsub(/\Atitle\:/, "").strip
      elsif line.match(/\Amodule_name\:/)
        resp[:module_name] = line.gsub(/\Amodule_name\:/, "").strip
      elsif line.match(/\Apublish_date\:/)
        resp[:publish_date] = line.gsub(/\Apublish_date\:/, "").strip
      elsif line.match(/\Acves\:/)
        resp[:cves] = line.gsub(/\Acves\:/, "").strip
      elsif line.match(/\Avulnerable_versions\:/)
        resp[:vulnerable_versions] = line.gsub(/\Avulnerable_versions\:/, "").gsub("\"", "").strip
      elsif line.match(/\Apatched_versions\:/)
        resp[:patched_versions] = line.gsub(/\Apatched_versions\:/, "").strip
      end
    end
    resp
  end


  def self.fetch_sv prod_key, title
    return nil if prod_key.to_s.empty? || title.to_s.empty?

    svs = SecurityVulnerability.by_language( Product::A_LANGUAGE_NODEJS ).by_prod_key( prod_key )
    svs.each do |sv|
      next if sv.nil?
      return sv if sv.summary.to_s.eql?(title)
    end

    self.logger.info "Create new SecurityVulnerability for #{Product::A_LANGUAGE_NODEJS}:#{prod_key} - #{title}"
    SecurityVulnerability.new(:language => Product::A_LANGUAGE_NODEJS, :prod_key => prod_key, :summary => title )
  end


end
