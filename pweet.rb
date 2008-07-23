["rubygems", "rest_client", "hpricot", "rmagick", "fileutils"].each {|lib| require lib}

get '/:user/statuses/:id.png' do
  begin
    xhtml = Hpricot(RestClient.get("http://twitter.com/#{params[:user]}/statuses/#{params[:id]}", :accept => 'text/html'))
    tweet = (xhtml/"div.desc"/"p")[0].innerText.strip
    author = (xhtml/"h2.thumb"/"a")[1].innerText.strip
  rescue => e
    stop 404 
  end

  stop 404 unless tweet && author

  canvas = Magick::ImageList.new("public/pweet.png")
  tweet_img = Magick::Image.read("caption:#{tweet}") { 
    self.size = "250x" 
    self.background_color = "transparent"
    self.pointsize = 14
    self.font = "helvetica-bold" 
  }[0]

  author_img = Magick::Image.read("caption:#{author}") { 
    self.size = "180x" 
    self.background_color = "transparent"
    self.gravity = Magick::EastGravity
    self.pointsize = 12
    self.font = "helvetica-boldoblique" 
  }[0]
  
  final = canvas.composite(tweet_img, 25, 23, Magick::OverCompositeOp).composite(author_img, 100, 100, Magick::OverCompositeOp)

  FileUtils.mkdir_p("public/#{params[:user]}/statuses/")
  final.write("public/#{params[:user]}/statuses/#{params[:id]}.png")

  header 'Content-Type' => 'image/png'
  final.to_blob
end