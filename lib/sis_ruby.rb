# Load all *.rb files in lib/sis_ruby and below.
# Use a lambda so that the intermediate variables do not survive this file.
->() {
  start_dir = File.join(File.dirname(__FILE__), 'sis_ruby') # the lib directory
  file_mask = "#{start_dir}/**/*.rb"
  Dir[file_mask].each { |file| require file }
}.()

