# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: ruby_crawl 1.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "ruby_crawl"
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["reiz"]
  s.date = "2016-05-06"
  s.description = "VersionEye crawlers implemented in Ruby"
  s.email = "robert.reiz.81@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".ruby-version",
    "Dockerfile",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "circle.yml",
    "config/mongoid.yml",
    "config/mongoid.yml.ci",
    "config/settings.json",
    "lib/versioneye-security.rb",
    "lib/versioneye/common_security.rb",
    "lib/versioneye/java_security_crawler.rb",
    "lib/versioneye/php_magento_crawler.rb",
    "lib/versioneye/php_sensiolabs_crawler.rb",
    "lib/versioneye/producers/producer.rb",
    "lib/versioneye/producers/security_producer.rb",
    "lib/versioneye/python_security_crawler.rb",
    "lib/versioneye/ruby_security_crawler.rb",
    "lib/versioneye/workers/security_worker.rb",
    "lib/versioneye/workers/worker.rb",
    "log/.keep_it",
    "ruby_crawl.gemspec",
    "scripts/major.sh",
    "scripts/minor.sh",
    "scripts/patch.sh",
    "scripts/run_tests_local.sh",
    "spec/spec_helper.rb",
    "spec/versioneye/domain_factories/product_factory.rb",
    "spec/versioneye/domain_factories/user_factory.rb",
    "spec/versioneye/java_security_crawler_spec.rb",
    "spec/versioneye/php_magento_crawler_spec.rb",
    "spec/versioneye/php_sensiolabs_crawler_spec.rb",
    "spec/versioneye/python_security_crawler_spec.rb",
    "spec/versioneye/ruby_security_crawler_spec.rb",
    "supervisord.conf",
    "tasks/versioneye.rake",
    "versioneye-security.gemspec"
  ]
  s.homepage = "http://github.com/reiz/ruby_crawl"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "VersionEye crawlers implemented in Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<bundler>, ["~> 1.12.0"])
      s.add_runtime_dependency(%q<syck>, ["= 1.1.0"])
      s.add_runtime_dependency(%q<versioneye-core>, [">= 0"])
      s.add_runtime_dependency(%q<rufus-scheduler>, ["= 3.2.0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.2.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.1.0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.12.0"])
      s.add_dependency(%q<syck>, ["= 1.1.0"])
      s.add_dependency(%q<versioneye-core>, [">= 0"])
      s.add_dependency(%q<rufus-scheduler>, ["= 3.2.0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<rdoc>, ["~> 4.2.0"])
      s.add_dependency(%q<jeweler>, ["~> 2.1.0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.12.0"])
    s.add_dependency(%q<syck>, ["= 1.1.0"])
    s.add_dependency(%q<versioneye-core>, [">= 0"])
    s.add_dependency(%q<rufus-scheduler>, ["= 3.2.0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<rdoc>, ["~> 4.2.0"])
    s.add_dependency(%q<jeweler>, ["~> 2.1.0"])
  end
end

