# require 'ruby_crawl'

require 'rufus-scheduler'
require 'versioneye-core'
require './lib/versioneye-security'

namespace :versioneye do

  desc "start scheduler for crawl_r prod"
  task :scheduler_security_prod do
    VersioneyeSecurity.new
    scheduler = Rufus::Scheduler.new

    # Crawl it once a hour. A crawl takes ~ 1 minutes!
    value = '35 * * * *'
    if !value.to_s.empty?
      scheduler.cron value do
        CommonCrawlProducer.new "::security_sensiolabs::"
      end
    end

    scheduler.join
    while 1 == 1
      p "keep alive rake task"
      sleep 30
    end
  end


  # ***** Crawler Tasks *****

  desc "Start SecuritySensiolabsCrawler"
  task :crawl_security_sensiolabs do
    puts "START SecuritySensiolabsCrawler"
    VersioneyeSecurity.new
    SecuritySensiolabsCrawler.crawl
    puts "---"
  end

end
