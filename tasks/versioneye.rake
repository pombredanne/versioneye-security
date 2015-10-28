require 'rufus-scheduler'
require 'versioneye-core'
require './lib/versioneye-security'

namespace :versioneye do

  desc "start scheduler for crawl_r prod"
  task :scheduler_security_prod do
    VersioneyeSecurity.new
    scheduler = Rufus::Scheduler.new

    # Crawl it once a hour.
    value = '34 * * * *'
    scheduler.cron value do
      SecurityProducer.new "php_magento"
    end

    value = '35 * * * *'
    scheduler.cron value do
      SecurityProducer.new "php_sensiolabs"
    end

    value = '40 * * * *'
    scheduler.cron value do
      SecurityProducer.new "node_security"
    end

    value = '50 * * * *'
    scheduler.cron value do
      SecurityProducer.new "ruby_security"
    end

    scheduler.join
    while 1 == 1
      p "keep alive rake task"
      sleep 30
    end
  end


  # ***** Crawler Tasks *****

  desc "Start SecurityWorker"
  task :security_worker do
    puts "START SecurityWorker"
    VersioneyeSecurity.new
    SecurityWorker.new.work
    puts "---"
  end

  desc "Start PhpSensiolabsCrawler"
  task :crawl_security_sensiolabs do
    puts "START PhpSensiolabsCrawler"
    VersioneyeSecurity.new
    PhpSensiolabsCrawler.crawl
    puts "---"
  end

  desc "Start NodeSecurityCrawler"
  task :crawl_node_security do
    puts "START NodeSecurityCrawler"
    VersioneyeSecurity.new
    NodeSecurityCrawler.crawl
    puts "---"
  end

  desc "Start RubySecurityCrawler"
  task :crawl_ruby_security do
    puts "START RubySecurityCrawler"
    VersioneyeSecurity.new
    RubySecurityCrawler.crawl
    puts "---"
  end

  desc "Start JavaSecurityCrawler"
  task :crawl_java_security do
    puts "START JavaSecurityCrawler"
    VersioneyeSecurity.new
    JavaSecurityCrawler.crawl
    puts "---"
  end

end
