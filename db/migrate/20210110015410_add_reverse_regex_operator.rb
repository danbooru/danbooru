class AddReverseRegexOperator < ActiveRecord::Migration[6.1]
  def up
    execute "CREATE FUNCTION reverse_textregexeq (text, text) RETURNS boolean LANGUAGE sql IMMUTABLE PARALLEL SAFE AS $$ SELECT textregexeq($2, $1); $$"
    execute "CREATE OPERATOR ~<< (FUNCTION = reverse_textregexeq, leftarg = text, rightarg = text)"
  end

  def down
    execute "DROP OPERATOR ~<< (text, text)"
    execute "DROP FUNCTION reverse_textregexeq (text, text)"
  end
end
