# NOTE: Google::Speech API uses GRPC for async operations which cannot be mocked
#   via VCR so they have been globally disabled in the suite.
# If an important change is applied to transcription algorithm set +gcs+ flag
#   to false and remove cassette for complete ingregation test.
shared_examples_for 'transcribable', gcs: true do
  # the class that includes the concern
  let!(:model) do
    described_class
  end

  let!(:transcribable) do
    factory_name = model.name.underscore.to_sym
    create(factory_name,
           transcript: nil,
           # must be existing s3 file
           audiofile: 'https://cdn-gcomm.s3.amazonaws.com/calls/gtel-dc21e062-b753-47c8-b0b2-265dbede1b6c/300-gtel-dc21e062-b753-47c8-b0b2-265dbede1b6c-1523066004.wav')
  end

  it 'should transcribe if audiofile exists' do
    VCR.use_cassette('create_job_transcribe',
                     match_requests_on: [:transcribe]) do
      transcribable.aws_transcribe!
      # data expectations
      expect(transcribable.transcript).to be_present
      expect(transcribable.transcript_data).to be_present
    end
  end
end
