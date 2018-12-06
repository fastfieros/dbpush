# dbpush

Command line utility to push local file to dropbox. 

## Prerequsites
dropbox-sdk-v2:  This can be installed with bundler via `bundle install` or using the gem directly via `gem install dropbox-sdk-v2`.

## Usage
```
Usage: dbpush.rb --token=TOKEN --file=FILE
    -t, --token=TOKEN                Dropbox account API Token
    -f, --file=FILE                  Local file path to upload to Dropbox
```