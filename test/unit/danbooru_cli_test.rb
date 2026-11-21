require "test_helper"

class DanbooruCLITest < ActiveSupport::TestCase
  include IqdbTestHelper

  # Run a booructl command and return its stdout, stderr, and whether it succeeded.
  def booructl(*argv, stdin: "")
    success = true
    old_stdin = $stdin
    $stdin = StringIO.new(stdin)

    stdout, stderr = capture_subprocess_io do
      Danbooru::CLI.start(argv)
    rescue SystemExit => e
      success = e.success?
    end

    [stdout, stderr, success]
  ensure
    $stdin = old_stdin
  end

  context "booructl" do
    should "work when called with bin/booructl" do
      assert_equal(true, system(Rails.root.join("bin/booructl help > /dev/null 2>&1").to_s))
    end

    should "fail on an unknown command" do
      _, stderr, success = booructl("nonexistent")

      assert_equal(false, success)
      assert_match(/Could not find command/, stderr)
    end

    context "status command" do
      should "show the status of the instance" do
        stdout, = booructl("status")

        assert_match(/^Postgres:\s+up/, stdout)
        assert_match(/^Migrations:\s+up to date/, stdout)
        assert_match(/^Storage:\s+StorageManager::Local/, stdout)
        assert_match(/^IQDB:\s+disabled/, stdout)
      end
    end

    context "user create command" do
      should "create a user with the password from stdin" do
        stdout, _, success = booructl("user", "create", "alice", "--password-stdin", stdin: "password123\n")
        user = User.find_by_name("alice")

        assert_equal(true, success)
        assert_match(/Created user alice/, stdout)
        assert_equal(User::Levels::MEMBER, user.level)
        assert_equal(user, user.authenticate_password("password123"))
      end

      should "create a user with the given level" do
        _, _, success = booructl("user", "create", "alice", "--level", "admin", "--password-stdin", stdin: "password123\n")
        user = User.find_by_name("alice")

        assert_equal(true, success)
        assert_equal(User::Levels::ADMIN, user.level)
        assert_equal("user_level_change", ModAction.last.category)
        assert_equal(User.system, ModAction.last.creator)
      end

      should "fail for an invalid username" do
        _, stderr, success = booructl("user", "create", "bad name!", "--password-stdin", stdin: "password123\n")

        assert_equal(false, success)
        assert_match(/Name/, stderr)
        assert_equal(false, User.exists?(name: "bad name!"))
      end

      should "fail for an invalid level" do
        _, stderr, success = booructl("user", "create", "alice", "--level", "superuser", "--password-stdin", stdin: "password123\n")

        assert_equal(false, success)
        assert_match(/Invalid level/, stderr)
        assert_equal(false, User.exists?(name: "alice"))
      end

      should "fail if no password is given and stdin isn't a terminal" do
        _, stderr, success = booructl("user", "create", "alice")

        assert_equal(false, success)
        assert_match(/--password-stdin/, stderr)
        assert_equal(false, User.exists?(name: "alice"))
      end
    end

    context "user set-level command" do
      setup do
        @user = create(:user, name: "alice")
      end

      should "promote a user to any level, including superadmin" do
        stdout, _, success = booructl("user", "set-level", "alice", "Superadmin")

        assert_equal(true, success)
        assert_match(/alice is now Superadmin/, stdout)
        assert_equal(User::Levels::SUPERADMIN, @user.reload.level)
        assert_equal(User.system, ModAction.last.creator)
        assert_match(/promoted "alice"/, ModAction.last.description)
      end

      should "demote a user" do
        @user.update!(level: User::Levels::ADMIN)
        _, _, success = booructl("user", "set-level", "alice", "member")

        assert_equal(true, success)
        assert_equal(User::Levels::MEMBER, @user.reload.level)
        assert_match(/demoted "alice"/, ModAction.last.description)
      end

      should "do nothing if the user is already at the given level" do
        assert_no_difference(["ModAction.count", "Dmail.count", "UserFeedback.count"]) do
          _, _, success = booructl("user", "set-level", "alice", "member")
          assert_equal(true, success)
        end
      end

      should "not demote the only superadmin" do
        @user.update!(level: User::Levels::SUPERADMIN)
        _, stderr, success = booructl("user", "set-level", "alice", "admin")

        assert_equal(false, success)
        assert_match(/only Superadmin/, stderr)
        assert_equal(User::Levels::SUPERADMIN, @user.reload.level)
      end

      should "demote a superadmin if there's another superadmin" do
        create(:user, level: User::Levels::SUPERADMIN)
        @user.update!(level: User::Levels::SUPERADMIN)
        _, _, success = booructl("user", "set-level", "alice", "admin")

        assert_equal(true, success)
        assert_equal(User::Levels::ADMIN, @user.reload.level)
      end

      should "fail for a nonexistent user" do
        _, stderr, success = booructl("user", "set-level", "nobody", "admin")

        assert_equal(false, success)
        assert_match(/User 'nobody' not found/, stderr)
      end

      should "fail for an invalid level" do
        _, stderr, success = booructl("user", "set-level", "alice", "anonymous")

        assert_equal(false, success)
        assert_match(/Invalid level/, stderr)
        assert_equal(User::Levels::MEMBER, @user.reload.level)
      end

      should "fail with the validation error if the user is invalid" do
        @user.per_page = 1000
        @user.save!(validate: false)
        _, stderr, success = booructl("user", "set-level", "alice", "admin")

        assert_equal(false, success)
        assert_match(/Posts per page must be between/, stderr)
        assert_equal(User::Levels::MEMBER, @user.reload.level)
      end
    end

    context "db commands" do
      should "print the commands they run, without the password" do
        Danbooru::CLI::DbCommand.any_instance.stubs(:pg_env).returns({ "PGHOST" => "db.example.com", "PGUSER" => "danbooru", "PGPASSWORD" => "hunter2", "PGDATABASE" => "danbooru" })
        _, stderr, success = booructl("db", "backup", "-o", "db.pg_dump", "--dry-run")

        assert_equal(true, success)
        assert_equal("$ pg_dump --host=db.example.com --username=danbooru --dbname=danbooru --format=custom --compress=zstd --file db.pg_dump\n", stderr)
        assert_no_match(/hunter2/, stderr)
      end

      should "back up and check the database" do
        Danbooru::Tempdir.create do |dir|
          backup = File.join(dir.path, "db.pg_dump")
          _, _, success = booructl("db", "backup", "-o", backup)
          assert_equal(true, success)

          stdout, stderr, success = booructl("db", "check", backup)
          assert_equal(true, success)
          assert_equal("$ pg_restore --file=- -- #{backup}\n", stderr)
          assert_match(/The backup has \d+ tables, \d+ rows, and \d+ indexes/, stdout)
        end
      end

      should "fail to check a corrupt backup" do
        Danbooru::Tempfile.create do |file|
          file.write("garbage")
          file.flush
          stdout, stderr, success = booructl("db", "check", file.path)

          assert_equal(false, success)
          assert_empty(stdout)
          assert_match(/incomplete or corrupt/, stderr)
        end
      end

      should "not write a backup in dry run mode" do
        Danbooru::Tempdir.create do |dir|
          backup = File.join(dir.path, "db.pg_dump")
          _, stderr, success = booructl("db", "backup", "-o", backup, "--dry-run")

          assert_equal(true, success)
          assert_match(/^\$ pg_dump /, stderr)
          assert_equal(false, File.exist?(backup))
        end
      end

      should "refuse to restore into a non-empty database" do
        _, stderr, success = booructl("db", "restore", File::NULL)

        assert_equal(false, success)
        assert_match(/isn't empty/, stderr)
      end

      should "not reset the database without confirmation" do
        _, stderr, success = booructl("db", "reset")

        assert_equal(false, success)
        assert_match(/--yes/, stderr)
        assert_equal(true, ActiveRecord::Base.connection.tables.any?)
      end

      should "not reset the database in dry run mode" do
        database = ActiveRecord::Base.connection.current_database
        _, stderr, success = booructl("db", "reset", "--dry-run")

        assert_equal(true, success)
        assert_match(/^\$ dropdb .*--if-exists --force -- #{database}$/, stderr)
        assert_match(/^\$ createdb .* -- #{database}$/, stderr)
        assert_match(%r{^\$ \S*bin/rails db:schema:load db:seed$}, stderr)
        assert_equal(true, ActiveRecord::Base.connection.tables.any?)
      end

      should "not load the schema when resetting with --empty" do
        _, stderr, success = booructl("db", "reset", "--empty", "--dry-run")

        assert_equal(true, success)
        assert_match(/^\$ createdb /, stderr)
        assert_no_match(/db:schema:load/, stderr)
      end

      should "empty the database before restoring with --force" do
        database = ActiveRecord::Base.connection.current_database
        _, stderr, success = booructl("db", "restore", "backup.pg_dump", "--force", "--dry-run")

        assert_equal(true, success)
        assert_match(/^\$ dropdb .* -- #{database}\n\$ createdb .* -- #{database}\n\$ pg_restore .* -- backup.pg_dump$/, stderr)
        assert_no_match(/db:schema:load/, stderr)
        assert_equal(true, ActiveRecord::Base.connection.tables.any?)
      end
    end

    context "images commands" do
      setup do
        @variant = create(:post_with_file).media_asset.variant(:original)
      end

      should "back up, check, and restore images" do
        Danbooru::Tempdir.create do |dir|
          backup = File.join(dir.path, "images.tar")
          _, stderr, success = booructl("images", "backup", "-o", backup)
          assert_equal(true, success)
          assert_match(/^\$ tar --create --file #{Regexp.escape(backup)} --directory #{Regexp.escape(@temp_dir)} \.$/, stderr)

          stdout, stderr, success = booructl("images", "check", backup)
          assert_equal(true, success)
          assert_equal("$ tar --list --verbose --file #{backup}\n", stderr)
          assert_match(/^The backup has 1 image \(4 files, [\d.]+ KB\)\.$/, stdout)

          FileUtils.rm_rf(Dir.glob("#{@temp_dir}/*"))
          assert_nil(@variant.open_file)

          stdout, stderr, success = booructl("images", "restore", backup)
          assert_equal(true, success)
          assert_equal("$ tar --extract --verbose --verbose --file #{backup} --directory #{@temp_dir} --no-same-owner --no-overwrite-dir\n", stderr)
          assert_match(/^Restored 1 image \(4 files, [\d.]+ KB\)\.$/, stdout)
          assert_not_nil(@variant.open_file)
        end
      end

      should "fail to check a corrupt backup" do
        Danbooru::Tempfile.create do |file|
          file.write("garbage")
          file.flush
          stdout, stderr, success = booructl("images", "check", file.path)

          assert_equal(false, success)
          assert_empty(stdout)
          assert_match(/incomplete or corrupt/, stderr)
        end
      end

      should "not write a backup in dry run mode" do
        Danbooru::Tempdir.create do |dir|
          backup = File.join(dir.path, "images.tar")
          _, stderr, success = booructl("images", "backup", "-o", backup, "--dry-run")

          assert_equal(true, success)
          assert_match(/^\$ tar --create /, stderr)
          assert_equal(false, File.exist?(backup))
        end
      end

      should "delete all images on reset" do
        _, stderr, success = booructl("images", "reset", "--yes")

        assert_equal(true, success)
        assert_match(/^\$ find #{Regexp.escape(@temp_dir)} -mindepth 1 -delete$/, stderr)
        assert_nil(@variant.open_file)
        assert_equal(true, Dir.exist?(@temp_dir))
        assert_empty(Dir.children(@temp_dir))
      end

      should "not delete images without confirmation" do
        _, stderr, success = booructl("images", "reset")

        assert_equal(false, success)
        assert_match(/--yes/, stderr)
        assert_not_nil(@variant.open_file)
      end

      should "not delete images in dry run mode" do
        _, stderr, success = booructl("images", "reset", "--dry-run")

        assert_equal(true, success)
        assert_match(/^\$ find /, stderr)
        assert_not_nil(@variant.open_file)
      end

      should "refuse to work when images aren't stored locally" do
        Danbooru.config.stubs(:storage_manager).returns(StorageManager::Null.new)
        _, stderr, success = booructl("images", "backup", "-o", File::NULL)

        assert_equal(false, success)
        assert_match(/aren't stored locally/, stderr)
      end
    end

    context "instance commands" do
      setup do
        @variant = create(:post_with_file).media_asset.variant(:original)
      end

      should "back up and check the database and images" do
        Danbooru::Tempdir.create do |dir|
          backup_dir = File.join(dir.path, "backup")
          _, _, success = booructl("instance", "backup", backup_dir)
          assert_equal(true, success)
          assert_equal(%w[danbooru-database.pg_dump danbooru-images.tar], Dir.children(backup_dir).sort)

          stdout, _, success = booructl("instance", "check", backup_dir)
          assert_equal(true, success)
          assert_match(/The backup has \d+ tables/, stdout)
          assert_match(/The backup has 1 image \(4 files/, stdout)
        end
      end

      should "not write anything in dry run mode" do
        Danbooru::Tempdir.create do |dir|
          backup_dir = File.join(dir.path, "backup")
          _, stderr, success = booructl("instance", "backup", backup_dir, "--dry-run")

          assert_equal(true, success)
          assert_match(/^\$ pg_dump /, stderr)
          assert_match(/^\$ tar --create /, stderr)
          assert_equal(false, Dir.exist?(backup_dir))
        end
      end

      should "not reset without confirmation" do
        _, stderr, success = booructl("instance", "reset")

        assert_equal(false, success)
        assert_match(/--yes/, stderr)
        assert_not_nil(@variant.open_file)
      end

      should "print the commands to reset the database and images in dry run mode" do
        _, stderr, success = booructl("instance", "reset", "--dry-run")

        assert_equal(true, success)
        assert_match(/^\$ dropdb /, stderr)
        assert_match(/^\$ createdb /, stderr)
        assert_match(/^\$ find /, stderr)
        assert_match(/db:schema:load db:seed/, stderr)
        assert_not_nil(@variant.open_file)
        assert_equal(true, ActiveRecord::Base.connection.tables.any?)
      end

      should "empty the database before restoring with --force" do
        Danbooru::Tempdir.create do |dir|
          _, stderr, success = booructl("instance", "restore", dir.path, "--force", "--dry-run")

          assert_equal(true, success)
          assert_match(/^\$ dropdb .*\n\$ createdb .*\n\$ pg_restore /, stderr)
          assert_match(/^\$ tar --extract /, stderr)
        end
      end
    end

    context "media regenerate command" do
      setup do
        @post = create(:post_with_file)
        @asset = @post.media_asset
      end

      should "regenerate missing thumbnails" do
        @asset.variant(:"180x180").delete_file!
        stdout, _, success = booructl("media", "regenerate", "--no-ai-tags")

        assert_equal(true, success)
        assert_match(/media asset ##{@asset.id}/, stdout)
        assert_nothing_raised { @asset.variant(:"180x180").open_file! }
      end

      should "only regenerate assets matching the search" do
        @asset.variant(:"180x180").delete_file!
        _, _, success = booructl("media", "regenerate", "id:#{@asset.id + 1}", "--no-ai-tags")

        assert_equal(true, success)
        assert_raises(Errno::ENOENT) { @asset.variant(:"180x180").open_file! }
      end

      should "not change anything in dry run mode" do
        @asset.variant(:"180x180").delete_file!
        stdout, _, success = booructl("media", "regenerate", "--dry-run")

        assert_equal(true, success)
        assert_match(/media asset ##{@asset.id}/, stdout)
        assert_raises(Errno::ENOENT) { @asset.variant(:"180x180").open_file! }
      end

      should "work when processing media assets in parallel" do
        ApplicationRecord.connection.stubs(:transaction_open?).returns(false)
        stdout, _, success = booructl("media", "regenerate", "id:>0", "--dry-run")

        assert_equal(true, success)
        assert_match(/media asset ##{@asset.id}/, stdout)
      end

      should "report failures and exit with an error" do
        @asset.variant(:original).delete_file!
        _, stderr, success = booructl("media", "regenerate", "--no-ai-tags")

        assert_equal(false, success)
        assert_match(/media asset ##{@asset.id}/, stderr)
      end
    end

    context "iqdb reindex command" do
      setup do
        @post = create(:post_with_file)
        @deleted_post = create(:post_with_file, filename: "png/test.png", is_deleted: true)
      end

      should "fail if IQDB isn't enabled" do
        _, stderr, success = booructl("iqdb", "reindex")

        assert_equal(false, success)
        assert_match(/IQDB isn't enabled/, stderr)
      end

      should "add all posts to IQDB, including deleted posts" do
        mock_iqdb_enable!
        IqdbClient.any_instance.expects(:add_post).with(@post)
        IqdbClient.any_instance.expects(:add_post).with(@deleted_post)

        stdout, _, success = booructl("iqdb", "reindex")

        assert_equal(true, success)
        assert_match(/post ##{@post.id}/, stdout)
        assert_match(/post ##{@deleted_post.id}/, stdout)
      end

      should "only add posts matching the search" do
        mock_iqdb_enable!
        IqdbClient.any_instance.expects(:add_post).with(@post).once
        IqdbClient.any_instance.expects(:add_post).with(@deleted_post).never

        _, _, success = booructl("iqdb", "reindex", "id:#{@post.id}")
        assert_equal(true, success)
      end

      should "work when processing posts in parallel" do
        # Outside of tests, parallel_find_each processes records in parallel instead of falling back to find_each.
        ApplicationRecord.connection.stubs(:transaction_open?).returns(false)
        mock_iqdb_enable!

        stdout, _, success = booructl("iqdb", "reindex", "--dry-run")

        assert_equal(true, success)
        assert_match(/post ##{@post.id}/, stdout)
        assert_match(/post ##{@deleted_post.id}/, stdout)
      end

      should "not change anything in dry run mode" do
        mock_iqdb_enable!
        IqdbClient.any_instance.expects(:add_post).never

        stdout, _, success = booructl("iqdb", "reindex", "--dry-run")

        assert_equal(true, success)
        assert_match(/post ##{@post.id}/, stdout)
      end
    end
  end
end
