module PostgresExtensions
  def columns(*params)
    super.reject {|x| x.sql_type == "tsvector"}
  end
end
