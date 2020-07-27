require 'spec_helper.rb'

module MyApp
  class Application
  end
end

unless defined? ApiClient
  class ApiClient
    def self.column_names
      ["enabled"]
    end
  end
end

describe Stitches::ApiClientAccessWrapper do
  let(:api_client) {
    double(ApiClient, id: 42)
  }
  before do
    Stitches.configuration.reset_to_defaults!
  end
  describe '#fetch_by_key' do
    context "cache is disabled" do
      before do
        expect(ApiClient).to receive(:find_by).and_return(api_client).twice
      end

      it "fetchs object from db twice" do
        expect(described_class.fetch_for_key("123").id).to eq(42)
        expect(described_class.fetch_for_key("123").id).to eq(42)
      end
    end

    context "cache is configured" do
      before do
        Stitches.configure do |config|
          config.max_cache_ttl  = 5
          config.max_cache_size = 10
        end

        expect(ApiClient).to receive(:find_by).and_return(api_client).once
      end

      it "fetchs object from cache" do
        expect(described_class.fetch_for_key("123").id).to eq(42)
        # This should hit the cache
        expect(described_class.fetch_for_key("123").id).to eq(42)
      end
    end
  end
end
