require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Puppet::Module::Tool::Repository do
  describe 'instances' do
    before do
      @repository = described_class.new('http://fake.com')
    end

    describe '#contact' do
      before do
        Net::HTTP.expects(:start)
      end
      context "when not given an :authenticate option" do
        it "should authenticate" do
          @repository.expects(:authenticate).never
          @repository.contact(nil)
        end        
      end
      context "when given an :authenticate option" do
        it "should authenticate" do
          @repository.expects(:authenticate)
          @repository.contact(nil, :authenticate => true)
        end
      end
    end

    describe '#authenticate' do
      before do
        @request = stub
        @repository.expects(:header)
        @repository.expects(:prompt).twice        
      end

      it "should set basic auth on the request" do
        @request.expects(:basic_auth)
        @repository.authenticate(@request)
      end      
    end

    describe '#retrieve' do
      before do
        @uri = URI.parse('http://some.url.com')
        @repository.cache.expects(:retrieve).with(@uri.to_s)
      end
      it "should access the cache" do
        @repository.retrieve(@uri.to_s)
      end
    end
    
  end
end
