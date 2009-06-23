# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def h_br(text)
    value = h(text)
    value.freeze # freeze しないと、gsub の中で $1 が tainted になる模様 (Ruby 1.8.5)
    value.gsub(/(https?:\/\/[\x21-\x7f]+)/){"<a href=\"#{safe_url($1)}\">#{$1}</a>"}.gsub(/(\r\n|[\r\n])/, "<br/>\n")
  end
end
