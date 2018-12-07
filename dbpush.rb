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

# Ensure that both required options were provided
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

# Read, and upload the first (maybe only) BLOCK_SIZE bytes of file
buf = infile.read(BLOCK_SIZE)
cursor = dbx.start_upload_session(buf)

# Continue uploading blocks while there is more data in the file
while (buf = infile.read(BLOCK_SIZE))
  # upload this block
  dbx.append_upload_session(cursor, buf)
end

# Complete the upload
dbx.finish_upload_session(cursor, filepath, "", mode:'overwrite')

print "Upload complete"
