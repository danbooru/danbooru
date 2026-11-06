require "test_helper"

class ExternalCommandTest < ActiveSupport::TestCase
  context "ExternalCommand.run" do
    should "return the output and status of the command" do
      output, status = ExternalCommand.run("echo hello")

      assert_equal("hello\n", output)
      assert_equal(true, status.success?)
    end

    should "kill commands that run longer than the timeout" do
      started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      error = assert_raises(ExternalCommand::TimeoutError) { ExternalCommand.run("sleep 30", timeout: 1) }

      assert_equal("sleep timed out after 1 seconds", error.message)
      assert_operator(Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at, :<, 10)
    end

    should "not let commands write core dumps" do
      output, _status = ExternalCommand.run("sh -c 'ulimit -c'")

      assert_equal("0\n", output)
    end

    should "not let commands use more memory than the memory limit" do
      _output, status = ExternalCommand.run(%{ruby --disable=jit -e 'puts 1'}, memory_limit: 500.megabytes)
      assert_equal(true, status.success?)

      output, status = ExternalCommand.run(%{ruby --disable=jit -e 'puts ("a" * 1_000_000_000).size'}, memory_limit: 500.megabytes)
      assert_equal(false, status.success?)
      assert_match(/NoMemoryError/, output)
    end

    should "not run commands through a shell" do
      output, _status = ExternalCommand.run("echo hello; echo world")

      assert_equal("hello; echo world\n", output)
    end

    should "not pass the environment to commands" do
      ENV["DANBOORU_EXTERNAL_COMMAND_TEST_SECRET"] = "secret"
      output, _status = ExternalCommand.run("env")

      assert_equal(ENV.slice(*ExternalCommand::ENVIRONMENT).keys.sort, output.lines.map { it.split("=").first }.sort)
    ensure
      ENV.delete("DANBOORU_EXTERNAL_COMMAND_TEST_SECRET")
    end
  end

  context "FFmpeg.shell!" do
    should "raise an FFmpeg error when the command times out" do
      error = assert_raises(FFmpeg::Error) { FFmpeg.shell!("sleep 30", timeout: 1) }
      assert_equal("sleep timed out after 1 seconds", error.message)
    end
  end
end
