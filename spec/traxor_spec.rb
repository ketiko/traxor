require 'tempfile'

RSpec.describe Traxor do
  it 'has a version number' do
    expect(Traxor::VERSION).not_to be nil
  end

  describe  '.logger' do
    subject { described_class.logger }

    it { is_expected.to be_an_instance_of(Logger) }
  end

  describe  '.initialize_logger' do
    context 'when using defaults' do
      subject(:logger) { described_class.initialize_logger }

      let(:message) { 'testing' }
      let(:formatted_log_output) { "[#{described_class.name}] INFO : #{message}\n" }

      it { expect(logger.level).to eq(Logger::INFO) }
      it { expect(logger.progname).to eq(described_class.name) }
      it { expect(logger.instance_variable_get(:@logdev).dev).to eq(STDOUT) }
      it do
        expect { logger.info(message) }.to output(formatted_log_output).to_stdout_from_any_process
      end
    end

    context 'when passing log_target' do
      subject(:logger) { described_class.initialize_logger(log_target) }

      let(:log_target) { Tempfile.new }

      after do
        log_target.unlink
      end

      it { expect(logger.instance_variable_get(:@logdev).dev.path).to eq(log_target.path) }
    end
  end
end
