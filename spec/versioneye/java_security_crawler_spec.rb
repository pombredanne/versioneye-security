require 'spec_helper'

describe JavaSecurityCrawler do

  describe 'mark_affected_versions' do

    it 'will mark the affected versions' do
      product = ProductFactory.create_for_maven 'junit', 'junit', '1.0.0'
      product.add_version('1.0.1')
      product.add_version('1.1.1')
      product.add_version('1.2.0')
      product.add_version('2.0.0')
      product.add_version('2.1.0')
      product.add_version('3.0.0')
      expect( product.save ).to be_truthy
      sv = SecurityVulnerability.new
      sv.language = product.language
      sv.prod_key = product.prod_key
      JavaSecurityCrawler.mark_affected_versions sv, ['<=1.1.1,1', '>=2.1']
      product.reload

      version = product.version_by_number '2.1.0'
      expect( version.sv_ids.first ).to eql(sv.ids)

      version = product.version_by_number '3.0.0'
      expect( version.sv_ids.first ).to eql(sv.ids)

      version = product.version_by_number '1.0.1'
      expect( version.sv_ids.first ).to eql(sv.ids)

      version = product.version_by_number '1.1.1'
      expect( version.sv_ids.first ).to eql(sv.ids)

      version = product.version_by_number '1.2.0'
      expect( version.sv_ids ).to be_empty
    end

    it 'will mark the affected versions' do
      product = ProductFactory.create_for_maven 'junit', 'junit', '1.0.0'
      product.add_version('1.0.1')
      product.add_version('1.1.1')
      product.add_version('1.2.0')
      product.add_version('2.0.0')
      product.add_version('2.1.0')
      product.add_version('3.0.0')
      expect( product.save ).to be_truthy

      sv = SecurityVulnerability.new
      sv.language = product.language
      sv.prod_key = product.prod_key
      JavaSecurityCrawler.mark_affected_versions sv, ['>=1.0.1,1', '2.1.0']
      product.reload

      version = product.version_by_number '1.0.0'
      expect( version.sv_ids ).to be_empty

      version = product.version_by_number '1.0.1'
      expect( version.sv_ids ).to_not be_empty
      expect( version.sv_ids.first ).to eql(sv.ids)

      version = product.version_by_number '1.1.1'
      expect( version.sv_ids.first ).to eql(sv.ids)

      version = product.version_by_number '1.2.0'
      expect( version.sv_ids.first ).to eql(sv.ids)

      version = product.version_by_number '2.0.0'
      expect( version.sv_ids ).to be_empty

      version = product.version_by_number '2.1.0'
      expect( version.sv_ids.first ).to eql(sv.ids)

      version = product.version_by_number '3.0.0'
      expect( version.sv_ids ).to be_empty
    end
  end

  describe 'crawl' do

    it "succeeds" do
      product = ProductFactory.create_for_maven 'org.codehaus.groovy', 'groovy-all', "1.7.0"
      product.save.should be_truthy
      product.versions.push( Version.new( { :version => "1.6.0" } ) )
      product.versions.push( Version.new( { :version => "1.8.0" } ) )
      product.versions.push( Version.new( { :version => "5.0.0" } ) )
      product.save.should be_truthy

      worker = Thread.new{ SecurityWorker.new.work }

      SecurityProducer.new("java_security")
      sleep 10

      worker.exit

      product = Product.fetch_product Product::A_LANGUAGE_JAVA, 'org.codehaus.groovy/groovy-all'
      product.version_by_number('1.7.0').sv_ids.should_not be_empty
      product.version_by_number('1.8.0').sv_ids.should_not be_empty
      product.version_by_number('5.0.0').sv_ids.should be_empty
    end

  end

end
