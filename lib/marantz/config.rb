module Marantz
  extend self
  VOLUME_THRESHOLD = 80.0

  def configure(&block)
    yield @config ||= Configuration.new
  end

  def config
    @config
  end

  class Configuration
    attr_accessor :endpoint, :max_volume
  end

  configure do |config|
    config.endpoint = 'http://127.0.0.1'
    config.max_volume = 50.0
  end
end
