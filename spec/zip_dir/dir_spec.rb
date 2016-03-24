require 'spec_helper'

describe ZipDir::Dir do
  let(:instance) { described_class.new }
  let(:tree_dir) { "spec/fixtures/tree" }

  describe "#generated?" do
    subject { instance.generated? }

    it "is false" do
      expect(subject).to eql false
    end

    context "after generating" do
      before { instance.generate(tree_dir) }

      it "should be true" do
        expect(subject).to eql true
      end
    end
  end

  describe "#cleanup" do
    subject { instance.cleanup }

    it "executes anyway" do
      subject
    end

    context "after generating" do
      before { instance.generate(tree_dir) }

      it "cleans up copy path" do
        expect(instance.copy_path).to_not eql nil
        copy_path = instance.copy_path

        subject

        expect(instance.copy_path).to eql nil
        expect(File.directory?(copy_path)).to eql false
      end
    end
  end

  describe "#generate" do
    let(:options) { {} }
    subject { instance.generate(tree_dir, options) }

    def test_filenames_and_images(glob_result)
      expect(clean_glob(instance.copy_path)).to match_array glob_result
      test_images(instance.copy_path)
    end

    it "copies the folder" do
      subject
      test_filenames_and_images ["/tree", "/tree/branch", "/tree/branch/branch_image1.png",
                                 "/tree/branch/branch_image2.png", "/tree/root_image.png"]
    end

    context "with :root_directory option" do
      let(:options) { { root_directory: true } }

      it "copies the folders in the folder" do
        subject
        test_filenames_and_images ["/branch", "/branch/branch_image1.png",
                                   "/branch/branch_image2.png", "/root_image.png"]
      end
    end

    context "with two folders" do
      subject do
        instance.generate do |instance|
          ["single", "tree"].each { |folder| instance.add_path "spec/fixtures/#{folder}", options }
        end
      end

      it "copies the folders" do
        subject
        test_filenames_and_images ["/single", "/single/single_image.png", "/tree", "/tree/branch",
                                   "/tree/branch/branch_image1.png", "/tree/branch/branch_image2.png",
                                   "/tree/root_image.png"]
      end

      context "with :root_directory option" do
        let(:options) { { root_directory: true } }

        it "copies the folders in the folders" do
          subject
          test_filenames_and_images ["/single_image.png", "/branch",
                                     "/branch/branch_image1.png", "/branch/branch_image2.png",
                                     "/root_image.png"]
        end
      end
    end
  end
end