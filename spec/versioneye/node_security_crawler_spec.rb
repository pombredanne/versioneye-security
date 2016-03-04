require 'spec_helper'

describe NodeSecurityCrawler do

  describe 'crawl' do

    # it "succeeds" do
    #   product = ProductFactory.create_for_npm 'serve-static', "1.8.0"
    #   product.save.should be_truthy
    #   product.versions.push( Version.new( { :version => "1.6.0" } ) )
    #   product.versions.push( Version.new( { :version => "1.8.0" } ) )
    #   product.save.should be_truthy

    #   worker = Thread.new{ SecurityWorker.new.work }

    #   SecurityProducer.new("node_security")
    #   sleep 20

    #   worker.exit

    #   product = Product.fetch_product Product::A_LANGUAGE_NODEJS, 'serve-static'
    #   product.version_by_number('1.8.0').sv_ids.should be_empty
    #   product.version_by_number('1.6.0').sv_ids.should_not be_empty
    # end

  end

end
