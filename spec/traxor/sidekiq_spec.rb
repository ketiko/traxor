require 'traxor/sidekiq'

RSpec.describe Traxor::Sidekiq do
  describe '#call' do
    subject { described_class.new.call(worker, nil, queue) }

    let(:worker) { 'worker' }
    let(:queue) { 'queue' }

    pending
  end
end
