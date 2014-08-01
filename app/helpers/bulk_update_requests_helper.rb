module BulkUpdateRequestsHelper
  def script_with_line_breaks(script)
    escaped_script = script.gsub(/&/, "&amp;").gsub(/</, "&lt;").gsub(/>/, "&gt;")
    escaped_script.gsub(/\n/m, "<br>").html_safe
  end
end
