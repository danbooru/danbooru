require "test_helper"

require "socket"
require "timeout"

class PumaTest < ActiveSupport::TestCase
  context "Puma boot" do
    should "serve /up in single mode" do
      spawn_server(PUMA_WORKERS: 0) do |uri|
        response = Danbooru::Http.get("#{uri}/up")

        assert_equal(204, response.status.to_i)
      end
    end

    should "serve /up in cluster mode" do
      spawn_server(PUMA_WORKERS: 2) do |uri|
        response = Danbooru::Http.get("#{uri}/up")

        assert_equal(204, response.status.to_i)
      end
    end

    should "fail to boot when given invalid options" do
      error = assert_raises(RuntimeError) do
        spawn_server(PUMA_PORT: -1)
      end

      assert_equal("server exited unexpectedly", error.message)
    end
  end

  def spawn_server(**env)
    log_file = Danbooru::Tempfile.new("danbooru-puma-test-")
    port = TCPServer.open("localhost", 0) { |server| server.addr[1] } # reserve a random port
    uri = "http://localhost:#{port}"
    env = {
      PUMA_PORT: port,
      PUMA_CONTROL_URL: "tcp://localhost:0",
      **env,
    }.stringify_keys.transform_values(&:to_s)

    pid = Process.spawn(env, *%w[bin/rails server --no-daemon], chdir: Rails.root.to_s, out: log_file.path, err: log_file.path)
    wait_for_server(uri, pid)

    yield(uri) if block_given?
  ensure
    log_file&.close

    if process_running?(pid)
      Process.kill("TERM", pid)
      Timeout.timeout(5) { Process.wait(pid) }
    end
  end

  def wait_for_server(uri, pid)
    Timeout.timeout(30) do
      loop do
        raise "server exited unexpectedly" unless process_running?(pid)
        return if Danbooru::Http.timeout(1).get("#{uri}/up").status.to_i == 204

        sleep 0.1
      end
    end
  end

  def process_running?(pid)
    pid && Process.waitpid(pid, Process::WNOHANG).nil?
  rescue Errno::ECHILD
    false
  end
end
