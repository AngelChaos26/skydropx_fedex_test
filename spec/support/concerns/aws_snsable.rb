shared_examples_for 'aws_snsable' do
  # the class that includes the concern
  let(:model) do
    described_class
  end
  let!(:aws_snsable) do
    factory_name = model.name.underscore.to_sym
    create(factory_name,
           support_code: '4k4b',
           mobile_phone: '524423678840'
         )
  end
  it 'should send a sms to the specified mobile_phone with support_code' do
    VCR.use_cassette('aws_sns_sms') do
      expect { aws_snsable.aws_send_sms!(
          aws_snsable.mobile_phone,
          I18n.t('model.concern.sns_snsable.sms_subject',
                  code: aws_snsable.support_code)
        )}.not_to raise_error
    end
  end
end
