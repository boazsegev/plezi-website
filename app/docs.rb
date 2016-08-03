# The basic website controller, to get you started
class DocsController
  # HTTP
  def index
    # return response << "Hello World!" # for a hello world app
    render('layout') { render('guides/index') }
  end

  def show
    doc = render("guides/#{params['id'.freeze]}")
    return false if doc.nil?
    @title = (doc.scan(/\<h1[^\>]*>([^\<]+)/) { |m| break m })[0]
    render('layout') { doc }
  end
end
