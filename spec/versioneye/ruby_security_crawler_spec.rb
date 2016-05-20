require 'spec_helper'

describe RubySecurityCrawler do

  describe 'crawl' do

    it "succeeds" do
      product = ProductFactory.create_for_gemfile 'will_paginate', "3.0.3"
      expect( product.save ).to be_truthy
      product.versions.push( Version.new( { :version => "3.0.7" } ) )
      expect( product.save ).to be_truthy

      worker = Thread.new{ SecurityWorker.new.work }

      SecurityProducer.new("ruby_security")
      sleep 10

      worker.exit

      product = Product.fetch_product Product::A_LANGUAGE_RUBY, 'will_paginate'
      expect( product.version_by_number('3.0.3').sv_ids ).to_not be_empty
      expect( product.version_by_number('3.0.7').sv_ids ).to be_empty
    end

    it "succeeds for " do
      Product.delete_all
      SecurityVulnerability.delete_all
      product = ProductFactory.create_for_gemfile 'actionpack', "3.0.0"
      expect( product.save ).to be_truthy
      product.versions.push( Version.new( { :version => "3.1.0" } ) )
      product.versions.push( Version.new( { :version => "3.2.0" } ) )
      product.versions.push( Version.new( { :version => "4.2.5.2" } ) )
      product.versions.push( Version.new( { :version => "4.2.6" } ) )
      expect( product.save ).to be_truthy

      worker = Thread.new{ SecurityWorker.new.work }

      SecurityProducer.new("ruby_security")
      sleep 10

      worker.exit

      expect( SecurityVulnerability.where(:name_id => 'CVE-2016-2098').count ).to eq(1)
      sv = SecurityVulnerability.where(:name_id => 'CVE-2016-2098').first
      p "sv.ids: #{sv.ids}"
      expect( sv ).to_not be_nil

      product = Product.fetch_product Product::A_LANGUAGE_RUBY, 'actionpack'
      expect( product.version_by_number('3.0.0').sv_ids   ).to_not be_empty
      expect( product.version_by_number('3.1.0').sv_ids   ).to_not be_empty
      expect( product.version_by_number('3.2.0').sv_ids   ).to_not be_empty
      expect( product.version_by_number('4.2.5.2').sv_ids.include?(sv.ids) ).to be_falsey
      expect( product.version_by_number('4.2.6').sv_ids   ).to     be_empty
    end

  end

end
