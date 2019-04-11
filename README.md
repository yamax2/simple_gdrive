[![Build Status](https://travis-ci.org/yamax2/simple_gdrive.svg?branch=master)](https://travis-ci.org/yamax2/simple_gdrive)

# SimpleGdrive

[from this example](https://developers.google.com/drive/v3/web/quickstart/ruby)

Simple Google Drive file uploader

Creates a required folder and all its parents like `mkdir_p`. For example:

```
MyMoney/<year>/<month>/<type>/money.csv
```  

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple_gdrive'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_gdrive

## Usage with Rails

1. Create `client_secrets.json` using [this wizard](https://console.developers.google.com/start/api?id=drive)

2. Add the following initializer to `config/initializers`
```ruby
SimpleGdrive.configure do |config|  
  config.client_secrets_file = Rails.root.join('config', 'client_secrets.json') # required
  config.base_folder_id = '14lJD-WCxgCd9JxkBnsJktXhw0XrwrsLD' # required
  
  config.app_name = 'My app' # optional, default "GDrive Simple Uploader"
  config.credential_file = Rails.root.join('config', 'credentials.yaml') # optional, default ~/.credentials/gdrive-uploader.yaml  
end
```
3. Call `Authorizer.call` in console and follow instructions to create `credentials.yaml`.

### File upload
```ruby
SimpleGdrive.upload '2018/01/MyMoney/money.csv', 'money.csv'
```

folder id:<br>
![folder_id](https://mytm.tk/pcmsk/folder_id.png) 

import local csv to google drive table:
```ruby
CSV.open(tempfile_path, 'w', col_sep: "\t") do |output|
  output << ...
  ...
end

SimpleGdrive.upload 'my/reports/folder/report', 
                    tempfile_path, 
                    content_type: 'text/csv',
                    mime_type: 'application/vnd.google-apps.spreadsheet' 
```

### Folder clear
removes all files and folders in 
```ruby
SimpleGdrive.clear
```

option `move_to_trash`, default: `false`

### Trash clear
clears the user's trash bin
```ruby
SimpleGdrive.clear_trash
```

## Known issues

* incorrect behaviour with cyrillic symbols in filenames:
```ruby
SimpleGdrive.upload 'Расходы/01/money.csv', 'money.csv'
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
