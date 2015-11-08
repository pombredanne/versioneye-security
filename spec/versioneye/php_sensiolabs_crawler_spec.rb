require 'spec_helper'

describe PhpSensiolabsCrawler do

  describe 'crawle_scurity' do

    it "succeeds" do
      product = ProductFactory.create_for_composer 'firebase/php-jwt', "1.9.0"
      product.save.should be_truthy
      product.versions.push( Version.new( { :version => "1.9.1" } ) )
      product.versions.push( Version.new( { :version => "2.0.0" } ) )
      product.save.should be_truthy

      doctrine_cache = ProductFactory.create_for_composer 'doctrine/cache', "1.0.0"
      doctrine_cache.save.should be_truthy
      doctrine_cache.versions.push( Version.new( { :version => "1.1.0" } ) )
      doctrine_cache.versions.push( Version.new( { :version => "1.2.0" } ) )
      doctrine_cache.versions.push( Version.new( { :version => "1.3.0" } ) )
      doctrine_cache.versions.push( Version.new( { :version => "1.3.1" } ) )
      doctrine_cache.versions.push( Version.new( { :version => "1.3.2" } ) )
      doctrine_cache.versions.push( Version.new( { :version => "1.4.0" } ) )
      doctrine_cache.versions.push( Version.new( { :version => "1.4.1" } ) )
      doctrine_cache.versions.push( Version.new( { :version => "1.4.2" } ) )
      doctrine_cache.save.should be_truthy

      worker = Thread.new{ SecurityWorker.new.work }

      SecurityProducer.new("php_sensiolabs")
      sleep 30

      worker.exit

      product = Product.fetch_product "PHP", 'firebase/php-jwt'
      product.version_by_number('1.9.0').sv_ids.should_not be_empty
      product.version_by_number('2.0.0').sv_ids.should be_empty

      product = Product.fetch_product "PHP", 'doctrine/cache'
      product.version_by_number('1.0.0').sv_ids.should_not be_empty
      product.version_by_number('1.1.0').sv_ids.should_not be_empty
      product.version_by_number('1.2.0').sv_ids.should_not be_empty
      product.version_by_number('1.3.0').sv_ids.should_not be_empty
      product.version_by_number('1.3.1').sv_ids.should_not be_empty
      product.version_by_number('1.3.2').sv_ids.should be_empty
      product.version_by_number('1.4.0').sv_ids.should_not be_empty
      product.version_by_number('1.4.1').sv_ids.should_not be_empty
      product.version_by_number('1.4.2').sv_ids.should be_empty
    end

  end

end
