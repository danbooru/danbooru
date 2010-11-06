class Presenter
  def self.h(s)
    CGI.escapeHTML(s)
  end
  
  def self.u(s)
    URI.escape(s)
  end
  
  def h(s)
    CGI.escapeHTML(s)
  end
  
  def u(s)
    URI.escape(s)
  end
end
