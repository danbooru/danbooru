class Presenter
  def h(s)
    CGI.escapeHTML(s)
  end
  
  def u(s)
    URI.escape(s)
  end
end
