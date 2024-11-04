if ENV['GOOGLE_CLOUD_KEYFILE_JSON_BASE64']
    require 'tempfile'
    require 'base64'
  
    # Decode and write the credentials to a temporary file
    tempfile = Tempfile.new("google-cloud-keyfile")
    tempfile.write(Base64.decode64(ENV['GOOGLE_CLOUD_KEYFILE_JSON_BASE64']))
    tempfile.rewind
  
    # Set GOOGLE_APPLICATION_CREDENTIALS to the temporary file path
    ENV['GOOGLE_APPLICATION_CREDENTIALS'] = tempfile.path
  
    # Ensure the file persists for the duration of the app runtime
    at_exit { tempfile.close! }
  end
