require 'spec_helper'

describe PythonSecurityCrawler do

  describe 'crawl' do

    it "succeeds" do
      product = ProductFactory.create_for_pip 'keyring', "0.10.1"
      expect( product.save ).to be_truthy
      product.versions.push( Version.new( { :version => "0.1.0" } ) )
      product.versions.push( Version.new( { :version => "0.2.1" } ) )
      product.versions.push( Version.new( { :version => "1.0.0" } ) )
      expect( product.save ).to be_truthy

      product = ProductFactory.create_for_pip 'jinja2', "2.8.0"
      expect( product.save ).to be_truthy
      product.versions.push( Version.new( { :version => "2.7.3" } ) )
      product.versions.push( Version.new( { :version => "2.7.2" } ) )
      product.versions.push( Version.new( { :version => "2.7.1" } ) )
      product.versions.push( Version.new( { :version => "2.7" } ) )
      product.versions.push( Version.new( { :version => "2.6" } ) )
      product.versions.push( Version.new( { :version => "2.5.5" } ) )
      product.versions.push( Version.new( { :version => "2.5.4" } ) )
      product.versions.push( Version.new( { :version => "2.2.2" } ) )
      product.versions.push( Version.new( { :version => "2.1.0" } ) )
      product.versions.push( Version.new( { :version => "2.0.0" } ) )
      expect( product.save ).to be_truthy

      worker = Thread.new{ SecurityWorker.new.work }

      SecurityProducer.new("python_security")
      sleep 10

      worker.exit

      product = Product.fetch_product Product::A_LANGUAGE_PYTHON, 'keyring'
      product.version_by_number('0.10.1').sv_ids.should_not be_empty
      product.version_by_number('0.1.0' ).sv_ids.should_not be_empty
      product.version_by_number('0.2.1' ).sv_ids.should_not be_empty
      product.version_by_number('1.0.0' ).sv_ids.should be_empty

      product = Product.fetch_product Product::A_LANGUAGE_PYTHON, 'jinja2'
      expect( product.version_by_number('2.7.3').sv_ids ).to     be_empty
      expect( product.version_by_number('2.7.2').sv_ids ).to     be_empty
      expect( product.version_by_number('2.7.1').sv_ids ).to_not be_empty
      expect( product.version_by_number('2.7').sv_ids   ).to_not be_empty
      expect( product.version_by_number('2.6').sv_ids   ).to_not be_empty
      expect( product.version_by_number('2.5.5').sv_ids ).to_not be_empty
      expect( product.version_by_number('2.1.0').sv_ids ).to_not be_empty
      expect( product.version_by_number('2.0.0').sv_ids ).to     be_empty
    end

  end

end
