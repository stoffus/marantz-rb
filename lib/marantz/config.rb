module Marantz
  extend self
  VOLUME_THRESHOLD = 80.0
  COMMANDS = {
    volume: 'PutMasterVolumeSet/-%s',
    source: 'PutZone_InputFunction/%s',
    power: 'PutZone_OnOff/%s',
    mute: 'PutVolumeMute/%s'
  }
  PATHS = {
    main_zone: '/MainZone/index.put.asp',
    status: '/goform/formMainZone_MainZoneXml.xml'
  }
  SOURCES = {
    satellite: 'SAT/CBL',
    iradio: 'IRADIO',
    hdradio: 'HDRADIO',
    internet: 'NET/USB',
    cd: 'CD',
    tv: 'TV',
    dvd: 'DVD',
    aux: 'AUX',
    game: 'GAME',
    blueray: 'BD',
    spotify: 'SPOTIFY'
  }
  SUPPORTED_MODELS = {
    1 => 'SR7005',
    9 => 'SR5008'
  }

  def configure(&block)
    yield @config ||= Configuration.new
  end

  def config
    @config
  end

  class Configuration
    attr_accessor :host, :max_volume
  end

  configure do |config|
    config.host = '127.0.0.1'
    config.max_volume = 50.0
  end
end
