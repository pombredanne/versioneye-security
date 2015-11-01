require 'spec_helper'

describe PythonSecurityCrawler do

  describe 'crawl' do

    it "succeeds" do
      product = ProductFactory.create_for_pip 'keyring', "0.10.1"
      product.save.should be_truthy
      product.versions.push( Version.new( { :version => "0.1.0" } ) )
      product.versions.push( Version.new( { :version => "0.2.1" } ) )
      product.versions.push( Version.new( { :version => "1.0.0" } ) )
      product.save.should be_truthy

      worker = Thread.new{ SecurityWorker.new.work }

      SecurityProducer.new("python_security")
      sleep 10

      worker.exit

      product = Product.fetch_product Product::A_LANGUAGE_PYTHON, 'keyring'
      product.version_by_number('0.10.1').sv_ids.should_not be_empty
      product.version_by_number('0.1.0' ).sv_ids.should_not be_empty
      product.version_by_number('0.2.1' ).sv_ids.should_not be_empty
      product.version_by_number('1.0.0' ).sv_ids.should be_empty
    end

  end

end
