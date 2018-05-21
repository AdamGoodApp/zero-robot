describe ApplicationJob, type: :job do
  it 'rescues exceptions' do
    fakeJob = Class.new(ApplicationJob) do
      def perform
        raise 'stuff'
      end
    end

    expect(Rails.logger).to receive(:debug).with(/ActiveJob Exception: stuff/)
    fakeJob.perform_now
  end
end
