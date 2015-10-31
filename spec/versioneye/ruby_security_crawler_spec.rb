require 'spec_helper'

describe RubySecurityCrawler do

  describe 'crawl' do

    it "succeeds" do
      product = ProductFactory.create_for_gemfile 'will_paginate', "3.0.3"
      product.save.should be_truthy
      product.versions.push( Version.new( { :version => "3.0.7" } ) )
      product.save.should be_truthy

      worker = Thread.new{ SecurityWorker.new.work }

      SecurityProducer.new("ruby_security")
      sleep 10

      worker.exit

      product = Product.fetch_product Product::A_LANGUAGE_RUBY, 'will_paginate'
      product.version_by_number('3.0.3').sv_ids.should_not be_empty
      product.version_by_number('3.0.7').sv_ids.should be_empty
    end

  end

end
