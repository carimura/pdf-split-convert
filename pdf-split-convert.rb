require 'aws'
require 'mail'
require 'iron_worker_ng'
require 'iron_cache'
require 'zlib'
require 'base64'


def upload_to_s3(file, params)
  puts "\nUploading #{file} to s3..."

  s3 = Aws::S3Interface.new(params[:aws][:access], params[:aws][:secret])
  s3.create_bucket(params[:aws][:bucket])

  response = s3.put(params[:aws][:bucket], file, File.open(file))

  if response
    puts "Uploading succesful."
    link = s3.get_link(params[:aws][:bucket], file)
    puts "\nYou can view the file here on s3: ", link
  else
    puts "Error placing the file in s3."
  end
  link
end

def get_cache(params)
  cache_client = IronCache::Client.new(:token => params[:iron][:token], :project_id => params[:iron][:project_id])
  cache = cache_client.cache("pdf_pieces")
end


def get_and_split_pdf(params)
  puts "Getting PDF"
  puts `curl #{params[:url_in]} -o source.pdf`
  puts `curl https://s3.amazonaws.com/marketplace-test/libgcj.so.12 -o libgcj.so.12`

  puts "Splitting PDF"
  puts `./pdftk.sh source.pdf burst`
end

def queue_processors(params)
  puts "Running Queue Processor"
  i=1
  while i < 1000
    num = "%04d" % i
    filename = "pg_#{num}.pdf"

    #break if i==5

    if File.file?(filename)
      puts "#{filename} exists"

      params[:master] = false
      params[:file_out] = filename.gsub(/.pdf/, ".jpeg")
      params[:key] = "#{params[:url_in].gsub(/\//,"")}-#{filename}"

      cache = get_cache(params)
      cache.put(params[:key], Base64.encode64(Zlib.deflate(File.read(filename))))
      client = IronWorkerNG::Client.new(:token => params[:iron][:token], :project_id => params[:iron][:project_id])
      client.tasks.create("pdf-split-convert", params)
    else
      puts "#{filename} does not exist - Breaking"
      break
    end
    i+=1
  end
end


puts "----------------------------------------------------"

if params[:master]
  get_and_split_pdf(params)
  queue_processors(params)
else
  cache = get_cache(params)
  data = Zlib.inflate(Base64.decode64(cache.get(params[:key]).value))
  f = File.open('./page.pdf', 'w')
  f.write(data)
  f.close

  puts `convert -density 400 -units PixelsPerInch page.pdf -blur 1x65535 -blur 1x65535 -contrast -normalize -despeckle -despeckle -type grayscale -sharpen 1 -enhance #{params[:file_out]}`

  upload_to_s3(params[:file_out], params)
end

puts "----------------------------------------------------"


