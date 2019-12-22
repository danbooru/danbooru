require 'test_helper'

class TestJob < ApplicationJob
  def perform(record)
  end
end

class ApplicationJobTest < ActiveJob::TestCase
  context "An active job" do
    should "discard and log jobs with deserialization errors" do
      DanbooruLogger.expects(:log)

      assert_nothing_raised do
        perform_enqueued_jobs do
          tag = create(:tag, name: "tagme")
          tag.delete

          TestJob.perform_later(tag)
        end
      end
    end
  end
end
