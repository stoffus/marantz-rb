required_files = [
  'config',
  'exceptions',
  'client',
  'version'
]

required_files.each do |file|
  require "marantz/#{file}"
end
