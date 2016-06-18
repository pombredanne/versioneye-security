class JavaSecurityCrawler < CommonSecurity


  A_GIT_DB = "https://github.com/victims/victims-cve-db.git"


  def self.logger
    if !defined?(@@log) || @@log.nil?
      @@log = Versioneye::DynLog.new("log/java_security.log", 10).log
    end
    @@log
  end


  def self.crawl
    meassure_exec{ perform_crawl }
  end


  def self.perform_crawl
    db_dir = '/tmp/victims-cve-db'
    java_dir = '/tmp/victims-cve-db/database/java'

    `(cd /tmp && git clone #{A_GIT_DB})`
    `(cd #{db_dir} && git pull)`

    i = 0
    logger.info "start reading yaml files"
    all_yaml_files( java_dir ) do |filepath|
      i += 1
      logger.info "##{i} parse yaml: #{filepath}"
      parse_yaml filepath
    end
  end


  def self.parse_yaml filepath
    yml = Psych.load_file( filepath )
    yml['affected'].to_a.each do |affected|
      groupId    = affected['groupId']
      artifactId = affected['artifactId']
      prod_key   = "#{groupId}/#{artifactId}".downcase
      name_id    = yml["cve"]
      name_id    = filepath.split("/").last.gsub(".yaml", "").gsub(".yml", "") if name_id.to_s.strip.empty?

      sv = fetch_sv Product::A_LANGUAGE_JAVA, prod_key, name_id
      update( sv, yml, affected )
      mark_affected_versions( sv, affected['version'] )
      sv.save
    end
  rescue => e
    self.logger.error "ERROR in parse_yaml Message: #{e.message}"
    self.logger.error e.backtrace.join("\n")
  end


  def self.update sv, yml, affected
    sv.source      = 'victims-cve-db'
    sv.description = yml['description']
    sv.summary     = yml['title']
    sv.summary     = sv.name_id if sv.summary.to_s.empty?
    sv.cve         = yml['cve']
    sv.cvss_v2     = yml['cvss_v2']
    sv.affected_versions_string = affected['version'].to_a.join(" && ")
    sv.patched_versions_string  = affected['fixedin'].to_a.join(" && ")
    yml["references"].to_a.each do |reference|
      key = reference.gsub(".", "::")
      match = reference.match(/(CVE-.*)\z/i)
      if match
        key = match[0].gsub(/(\?.*)\z/, "").gsub(".", "_")
      end
      if sv.links && !sv.links.values.include?(reference)
        sv.links[key] = reference
      end
    end
  end


  def self.mark_affected_versions sv, affected
    product = sv.product
    return nil if product.nil?

    affected_versions = []
    affected.each do |version_expr|
      if version_expr.match(/,/)
        sps    = version_expr.split(",")
        condi  = sps[0]
        start  = sps[1]
        start  = "#{start}." if start.match(/-\z/).nil?
        subset = VersionService.versions_start_with( product.versions, start )
        affected_versions += VersionService.from_ranges( subset, condi )
        next
      end
      affected_versions += VersionService.from_ranges( product.versions, version_expr )
    end

    mark_versions( sv, product, affected_versions )
  end


end
