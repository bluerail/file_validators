require 'spec_helper'
require 'rack/test/uploaded_file'

describe 'File Content Type integration with ActiveModel' do
  class Person
    include ActiveModel::Validations
    attr_accessor :avatar
  end

  before :all do
    @cute_path = File.join(File.dirname(__FILE__), '../fixtures/cute.jpg')
    @chubby_bubble_path = File.join(File.dirname(__FILE__), '../fixtures/chubby_bubble.jpg')
    @chubby_cute_path = File.join(File.dirname(__FILE__), '../fixtures/chubby_cute.png')
    @sample_text_path = File.join(File.dirname(__FILE__), '../fixtures/sample.txt')
  end

  context ':allow option' do
    context 'a string' do
      before :all do
        Person.class_eval do
          Person.reset_callbacks(:validate)
          validates :avatar, file_content_type: { allow: 'image/jpeg' }
        end
      end

      subject { Person.new }

      context 'with an allowed type' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg') }
        it { is_expected.to be_valid }
      end

      context 'with a disallowed type' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@chubby_cute_path, 'image/png') }
        it { is_expected.not_to be_valid }
      end
    end

    context 'as a regex' do
      before :all do
        Person.class_eval do
          Person.reset_callbacks(:validate)
          validates :avatar, file_content_type: { allow: /^image\/.*/ }
        end
      end

      subject { Person.new }

      context 'with an allowed types' do
        it 'validates jpeg image file' do
          subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg')
          expect(subject).to be_valid
        end

        it 'validates png image file' do
          subject.avatar = Rack::Test::UploadedFile.new(@chubby_cute_path, 'image/png')
          expect(subject).to be_valid
        end
      end

      context 'with a disallowed type' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@sample_text_path, 'text/plain') }
        it { is_expected.not_to be_valid }
      end
    end

    context 'as a list' do
      before :all do
        Person.class_eval do
          Person.reset_callbacks(:validate)
          validates :avatar, file_content_type: { allow: ['image/jpeg', 'text/plain'] }
        end
      end

      subject { Person.new }

      context 'with allowed types' do
        it 'validates jpeg' do
          subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg')
          expect(subject).to be_valid
        end

        it 'validates text file' do
          subject.avatar = Rack::Test::UploadedFile.new(@sample_text_path, 'text/plain')
          expect(subject).to be_valid
        end
      end

      context 'with a disallowed type' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@chubby_cute_path, 'image/png') }
        it { is_expected.not_to be_valid }
      end
    end

    context 'as a proc' do
      before :all do
        Person.class_eval do
          Person.reset_callbacks(:validate)
          validates :avatar, file_content_type: { allow: lambda { |record| ['image/jpeg', 'text/plain'] } }
        end
      end

      subject { Person.new }

      context 'with allowed types' do
        it 'validates jpeg' do
          subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg')
          expect(subject).to be_valid
        end

        it 'validates text file' do
          subject.avatar = Rack::Test::UploadedFile.new(@sample_text_path, 'text/plain')
          expect(subject).to be_valid
        end
      end

      context 'with a disallowed type' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@chubby_cute_path, 'image/png') }
        it { is_expected.not_to be_valid }
      end
    end
  end

  context ':exclude option' do
    context 'a string' do
      before :all do
        Person.class_eval do
          Person.reset_callbacks(:validate)
          validates :avatar, file_content_type: { exclude: 'image/jpeg' }
        end
      end

      subject { Person.new }

      context 'with an allowed type' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@sample_text_path, 'text/plain') }
        it { is_expected.to be_valid }
      end

      context 'with a disallowed type' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg') }
        it { is_expected.not_to be_valid }
      end
    end

    context 'as a regex' do
      before :all do
        Person.class_eval do
          Person.reset_callbacks(:validate)
          validates :avatar, file_content_type: { exclude: /^image\/.*/ }
        end
      end

      subject { Person.new }

      context 'with an allowed type' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@sample_text_path, 'text/plain') }
        it { is_expected.to be_valid }
      end

      context 'with a disallowed types' do
        it 'invalidates jpeg image file' do
          subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg')
          expect(subject).not_to be_valid
        end

        it 'invalidates png image file' do
          subject.avatar = Rack::Test::UploadedFile.new(@chubby_cute_path, 'image/png')
          expect(subject).not_to be_valid
        end
      end
    end

    context 'as a list' do
      before :all do
        Person.class_eval do
          Person.reset_callbacks(:validate)
          validates :avatar, file_content_type: { exclude: ['image/jpeg', 'text/plain'] }
        end
      end

      subject { Person.new }

      context 'with an allowed type' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@chubby_cute_path, 'image/png') }
        it { is_expected.to be_valid }
      end

      context 'with a disallowed types' do
        it 'invalidates jpeg' do
          subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg')
          expect(subject).not_to be_valid
        end

        it 'invalidates text file' do
          subject.avatar = Rack::Test::UploadedFile.new(@sample_text_path, 'text/plain')
          expect(subject).not_to be_valid
        end
      end
    end

    context 'as a proc' do
      before :all do
        Person.class_eval do
          Person.reset_callbacks(:validate)
          validates :avatar, file_content_type: { exclude: lambda { |record| /^image\/.*/ } }
        end
      end

      subject { Person.new }

      context 'with an allowed type' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@sample_text_path, 'text/plain') }
        it { is_expected.to be_valid }
      end

      context 'with a disallowed types' do
        it 'invalidates jpeg image file' do
          subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg')
          expect(subject).not_to be_valid
        end
      end
    end
  end

  context ':allow and :exclude combined' do
    before :all do
      Person.class_eval do
        Person.reset_callbacks(:validate)
        validates :avatar, file_content_type: { allow: /^image\/.*/, exclude: 'image/png' }
      end
    end

    subject { Person.new }

    context 'with an allowed type' do
      before { subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg') }
      it { is_expected.to be_valid }
    end

    context 'with a disallowed type' do
      before { subject.avatar = Rack::Test::UploadedFile.new(@chubby_cute_path, 'image/png') }
      it { is_expected.not_to be_valid }
    end
  end
end
