require 'spec_helper'

describe PhpMagentoCrawler do

  describe 'crawle_scurity' do

    it "succeeds" do
      product = ProductFactory.create_for_composer 'connect20/aw_blog', "1.2.0"
      product.save.should be_truthy
      product.versions.push( Version.new( { :version => "1.3.0" } ) )
      product.versions.push( Version.new( { :version => "1.0.0" } ) )
      product.save.should be_truthy

      worker = Thread.new{ SecurityWorker.new.work }

      SecurityProducer.new("php_magento")
      sleep 20

      worker.exit

      product = Product.fetch_product "PHP", 'connect20/aw_blog'
      product.version_by_number('1.2.0').sv_ids.should_not be_empty
      product.version_by_number('1.3.0').sv_ids.should be_empty
    end

  end

end
