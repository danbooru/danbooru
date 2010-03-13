class Presenter
  def h(s)
    CGI.escapeHTML(s)
  end
end
