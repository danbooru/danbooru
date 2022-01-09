require_relative "../../config/environment"

# Run a block of code in a transaction, and only commit it after confirmation.
def with_confirmation(&block)
  ApplicationRecord.transaction do
    yield

    print "Commit? (yes/no): "
    raise "abort" unless STDIN.readline.chomp == "yes"
  end
end
