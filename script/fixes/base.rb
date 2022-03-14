require_relative "../../config/environment"

# Run a block of code in a transaction, and only commit it after confirmation.
def with_confirmation(&block)
  ApplicationRecord.transaction do
    CurrentUser.scoped(User.system, "127.0.0.1") do
      yield

      print "Commit? (yes/no): "
      raise "abort" unless STDIN.readline.chomp == "yes"
    end
  end
end
