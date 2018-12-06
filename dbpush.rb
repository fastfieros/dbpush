require 'dropbox'
require 'optparse'

#Max single upload is 150MB (https://github.com/dropbox/dropbox-sdk-js/issues/80)
BLOCK_SIZE = 1024*1024*150

# Parse command line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: dbpush.rb --token=TOKEN --file=FILE"

  opts.on("-tTOKEN", "--token=TOKEN", "Dropbox account API Token") do |t|
    options[:token] = t
  end

  opts.on("-fFILE", "--file=FILE", "Local file path to upload to Dropbox") do |f|
    options[:file] = f
  end
end.parse!

if not options.has_key? :token
  raise OptionParser::MissingArgument,"API token required"
end

if not options.has_key? :file
  raise OptionParser::MissingArgument,"File name required"
end

# Check if specified file exists
filename = options[:file]
File.file?(filename) || printf("%s does not exist!", filename)

# Use basename for target upload file name
filepath = "/" + File.basename(filename)

# Instantiate FILE and dropbox API handles
infile = File.new(filename, "rb")
dbx = Dropbox::Client.new(options[:token])

if infile.size > BLOCK_SIZE
  # if file is larger than BLOCK_SIZE, break into multiple requests
  # Start by creating an upload cursor

  buf = infile.read(BLOCK_SIZE)
  cursor = dbx.start_upload_session(buf)

  while (buf = infile.read(BLOCK_SIZE))
    # upload this block
    dbx.append_upload_session(cursor, buf)
  end

  # Complete the upload
  dbx.finish_upload_session(cursor, filepath, "", mode:'overwrite')

else
  # otherwise read file entire contents into memory
  filecontent = infile.read

  # Perform singular upload
  dbx.upload(filepath, filecontent, mode:'overwrite')

end

print "Upload complete"
