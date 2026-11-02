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

  context "Puma/Rack server limits" do
    should "reject request bodies that are too large" do
      spawn_server(DANBOORU_MAX_FILE_SIZE: 1024) do |uri|
        assert_equal(400, request_status(:get, uri, form: { q: "a" * 1022 })) # XXX GET requests with a body are rejected in `check_get_body` in application_controller.rb
        assert_equal(413, request_status(:get, uri, form: { q: "a" * 1024 }))
        assert_equal(200, request_status(:post, uri, form: { q: "a" * 1022 }))
        assert_equal(413, request_status(:post, uri, form: { q: "a" * 1024 }))
      end
    end

    should "reject query strings and urlencoded form bodies that are too large" do
      spawn_server(RACK_QUERY_PARSER_BYTESIZE_LIMIT: 1024) do |uri|
        assert_equal(200, request_status(:get, uri, params: { q: "a" * 1022 }))
        assert_equal(400, request_status(:get, uri, params: { q: "a" * 1024 }))
        assert_equal(200, request_status(:post, uri, form: { q: "a" * 1022 }))
        assert_equal(400, request_status(:post, uri, form: { q: "a" * 1024 }))
      end
    end

    should "reject JSON request bodies that are too large" do
      spawn_server(RACK_QUERY_PARSER_BYTESIZE_LIMIT: 1024) do |uri|
        assert_equal(200, request_status(:post, uri, headers: { "Content-Type" => "application/json" }, body: %({"q":"#{"a" * 1000}"})))
        assert_equal(400, request_status(:post, uri, headers: { "Content-Type" => "application/json" }, body: %({"q":"#{"a" * 1024}"})))
      end
    end

    should "reject query strings and urlencoded form bodies with too many parameters" do
      spawn_server(RACK_QUERY_PARSER_PARAMS_LIMIT: 2) do |uri|
        assert_equal(200, request_status(:get, uri, params: { a: 1, b: 2 }))
        assert_equal(400, request_status(:get, uri, params: { a: 1, b: 2, c: 3 }))
        assert_equal(200, request_status(:post, uri, form: { a: 1, b: 2 }))
        assert_equal(400, request_status(:post, uri, form: { a: 1, b: 2, c: 3 }))
      end
    end

    should "reject JSON request bodies with too many parameters" do
      spawn_server(RACK_QUERY_PARSER_PARAMS_LIMIT: 2) do |uri|
        assert_equal(200, request_status(:post, uri, json: { a: 1, b: 2 }))
        assert_equal(400, request_status(:post, uri, json: { a: 1, b: 2, c: 3 }))
        assert_equal(200, request_status(:post, uri, json: { a: { b: 1, c: 2 }, d: 3 }))
        assert_equal(400, request_status(:post, uri, json: { a: { b: 1 }, c: 2, d: 3 }))
      end
    end

    should "reject query strings and urlencoded form bodies with too deeply-nested parameters" do
      spawn_server(RACK_PARAM_DEPTH_LIMIT: 2) do |uri|
        assert_equal(200, request_status(:get, uri, params: { "a[b][c]" => 1 }))
        assert_equal(400, request_status(:get, uri, params: { "a[b][c][d]" => 1 }))
        assert_equal(200, request_status(:post, uri, form: { "a[b][c]" => 1 }))
        assert_equal(400, request_status(:post, uri, form: { "a[b][c][d]" => 1 }))
      end
    end

    should "reject JSON request bodies with too deeply-nested parameters" do
      spawn_server(RACK_PARAM_DEPTH_LIMIT: 2) do |uri|
        assert_equal(200, request_status(:post, uri, json: { a: { b: { c: 1 }}}))
        assert_equal(400, request_status(:post, uri, json: { a: { b: { c: { d: 1 }}}}))
        assert_equal(200, request_status(:post, uri, json: { a: [{ b: 1 }] }))
        assert_equal(400, request_status(:post, uri, json: { a: [{ b: [1] }] }))
      end
    end

    should "reject malformed JSON request bodies" do
      spawn_server do |uri|
        assert_equal(200, request_status(:post, uri, headers: { "Content-Type" => "application/json" }, body: '{"a": 1}'))
        assert_equal(400, request_status(:post, uri, headers: { "Content-Type" => "application/json" }, body: '{"a": '))
      end
    end

    should "reject multipart forms with too many files" do
      spawn_server(RACK_MULTIPART_FILE_LIMIT: 2) do |uri|
        files2 = 2.times.to_h { |i| [:"file#{i}", HTTP::FormData::File.new(StringIO.new("a"), filename: "#{i}.txt")] }
        files3 = 3.times.to_h { |i| [:"file#{i}", HTTP::FormData::File.new(StringIO.new("a"), filename: "#{i}.txt")] }

        assert_equal(200, request_status(:post, uri, form: files2))
        assert_equal(500, request_status(:post, uri, form: files3))
      end
    end

    should "reject multipart forms with too many non-file parameters" do
      spawn_server(RACK_MULTIPART_TOTAL_PART_LIMIT: 2) do |uri|
        parts2 = 2.times.to_h { |i| [:"part#{i}", HTTP::FormData::Part.new("a")] }
        parts3 = 3.times.to_h { |i| [:"part#{i}", HTTP::FormData::Part.new("a")] }

        assert_equal(200, request_status(:post, uri, form: parts2))
        assert_equal(500, request_status(:post, uri, form: parts3))
      end
    end

    should "reject multipart forms with too much non-file data" do
      spawn_server(RACK_MULTIPART_BUFFERED_UPLOAD_BYTESIZE_LIMIT: 1024) do |uri|
        assert_equal(200, request_status(:post, uri, form: { q: HTTP::FormData::Part.new("a" * 960) }))
        assert_equal(500, request_status(:post, uri, form: { q: HTTP::FormData::Part.new("a" * 1024) }))
      end
    end

    should "reject URLs that are too long" do
      spawn_server do |uri|
        assert_equal(200, request_status(:get, uri, params: { q: "a" * 1024 * 9 }))
        assert_equal(500, request_status(:get, uri, params: { q: "a" * 1024 * 10 }))
        assert_equal(200, request_status(:post, uri, params: { q: "a" * 1024 * 9 }))
        assert_equal(500, request_status(:post, uri, params: { q: "a" * 1024 * 10 }))
      end
    end

    should "reject requests with too many headers" do
      spawn_server do |uri|
        assert_equal(200, request_status(:get, uri, headers: 110.times.to_h { |i| ["X-#{i}", "a" * 1024] }))
        assert_equal(500, request_status(:get, uri, headers: 112.times.to_h { |i| ["X-#{i}", "a" * 1024] }))
      end
    end
  end

  def spawn_server(**env)
    log_file = Danbooru::Tempfile.new("danbooru-puma-test-")
    port = TCPServer.open("localhost", 0) { |server| server.addr[1] } # reserve a random port
    uri = "http://localhost:#{port}"
    env = {
      PUMA_PORT: port,
      PUMA_CONTROL_URL: "tcp://localhost:0",
      PUMA_WORKERS: 0,
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

  def request_status(verb, uri, headers: {}, **options)
    headers = { "Accept" => "application/json", "X-Http-Method-Override" => "GET", **headers }
    Danbooru::Http.public_send(verb, "#{uri}/posts", headers: headers, **options).status.to_i
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
