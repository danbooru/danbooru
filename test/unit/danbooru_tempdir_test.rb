require "test_helper"

class DanbooruTempdirTest < ActiveSupport::TestCase
  context "Danbooru::Tempdir" do
    should "delete the directory when it's closed" do
      dir = Danbooru::Tempdir.create
      dir.close

      assert_equal(false, File.exist?(dir.path))
    end

    should "not be deleted by a forked process" do
      # In a forked process, only the thread that forked keeps running, so a directory that another thread is using can be
      # garbage collected in the forked process.
      paths = Queue.new
      done = Queue.new
      thread = Thread.new do
        dir = Danbooru::Tempdir.create
        paths << dir.path
        done.pop
        dir.close
      end
      path = paths.pop

      pid = Process.fork do
        3.times { GC.start(full_mark: true, immediate_sweep: true) }
        sleep 0.1 # Let the finalizers run.
        exit!(0)
      end
      Process.wait(pid)

      assert_equal(true, File.exist?(path))
    ensure
      done << true
      thread&.join
    end
  end
end
