class NodeSecurityCrawler < CommonSecurity


  A_GIT_DB = "https://github.com/nodesecurity/nodesecurity-www.git"


  def self.logger
    ActiveSupport::Logger.new('log/node_security.log', 10, 2048000)
  end


  def self.crawl
    meassure_exec{ perform_crawl }
  end


  def self.perform_crawl
    db_dir = '/tmp/nodesecurity-www'

    `(cd /tmp && git clone #{A_GIT_DB})`
    `(cd #{db_dir} && git pull)`

    i = 0
    logger.info "start reading yaml files"
    all_md_files( "#{db_dir}/advisories" ) do |filepath|
      i += 1
      logger.info "##{i} parse yaml: #{filepath}"
      process_file filepath
    end
  end


  def self.all_md_files(dir, &block)
    Dir.glob "#{dir}/**/*.md" do |filepath|
      block.call filepath
    end
  end


  def self.process_file filepath
    content      = File.read( filepath )
    content_hash = parse content
    prod_key     = content_hash[:module_name]
    name_id      = filepath.split("/").last.gsub(".md", "")

    sv                          = fetch_sv Product::A_LANGUAGE_NODEJS, prod_key, name_id
    sv.summary                  = content_hash[:title]
    sv.author                   = content_hash[:author]
    sv.publish_date             = content_hash[:publish_date]
    sv.affected_versions_string = content_hash[:vulnerable_versions]
    sv.patched_versions_string  = content_hash[:patched_versions]
    sv.description              = content_hash[:description]

    parse_cve( sv, content_hash )
    mark_affected_versions( sv )
    sv.save
  rescue => e
    self.logger.error "ERROR in process_file: #{e.message}"
    self.logger.error e.backtrace.join("\n")
  end


  def self.parse_cve sv, content_hash
    cve_array = eval(content_hash[:cves])
    cve_array = eval( cve_array )
    return nil if cve_array.nil? || cve_array.empty?

    cve_array.each do |element|
      name = element[:name]
      link = element[:link]
      next if name.to_s.empty? || link.to_s.empty?

      sv.links[name.gsub(".", "")] = link
      sv.cve = name
    end
  rescue => e
    self.logger.error "ERROR in parse_cve: #{e.message}"
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
    lines = content.force_encoding(Encoding::UTF_8).split("\n")
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


end
