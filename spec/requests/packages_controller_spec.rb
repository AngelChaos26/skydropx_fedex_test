describe PackagesController do
  let!(:url) do
    packages_url
  end

  context 'public routes' do
    context 'GET /packages' do
      it 'should return a list of fedexs packages from API with overweight using the json provided' do
        VCR.use_cassette('fedex_tracking', match_requests_on: [:fedex_api]) do
          get packages_url
        end
        # status expectations
        expect(response).to have_http_status(:success)
        # data expectations
        package = json['packages'].first
        expect(package['tracking_number']).to be_present
        expect(package['package_weight']).to be_present
        expect(package['fedex_weight']).to be_present
        expect(package['overweight']).to be_present
        expect(package['overweight']).not_to eq(0.0)
        expect(package['message']).not_to be_present
        expect(json['packages'].count).to eq(6)
      end

      context 'should return a package with no overweight if label weight in platform is higher that fedex total weight' do
        it 'should return a list of fedexs packages from API with no overweight using a custom json, showing a message' do
          allow(Package).to receive(:package_file).and_return('spec/support/files/higher_weight.json')
          VCR.use_cassette('fedex_tracking_no_overweight', match_requests_on: [:fedex_api]) do
            get packages_url
          end
          # status expectations
          expect(response).to have_http_status(:success)
          # data expectations
          package = json['packages'].first
          expect(package['tracking_number']).to be_present
          expect(package['package_weight']).to be_present
          expect(package['fedex_weight']).to be_present
          expect(package['overweight']).to be_present
          expect(package['overweight']).to eq(0.0)
          expect(package['message']).to be_present
        end
      end

      context 'should return a package with no overweight if label volumetric weight in platform is higher that fedex total weight' do
        it 'should return a list of fedexs packages from API with no overweight using a custom json, showing a message' do
          allow(Package).to receive(:package_file).and_return('spec/support/files/higher_volumetric_weight.json')
          VCR.use_cassette('fedex_tracking_no_overweight_volumetric', match_requests_on: [:fedex_api]) do
            get packages_url
          end
          # status expectations
          expect(response).to have_http_status(:success)
          # data expectations
          package = json['packages'].first
          expect(package['tracking_number']).to be_present
          expect(package['package_weight']).to be_present
          expect(package['fedex_weight']).to be_present
          expect(package['overweight']).to be_present
          expect(package['overweight']).to eq(-1.0)
          expect(package['message']).to be_present
        end
      end
    end
  end
end
