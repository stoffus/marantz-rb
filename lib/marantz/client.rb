require 'yaml'
require 'xml'

module Marantz
  class Client
    def initialize
      @config = YAML.load_file(File.join(File.dirname(__FILE__), '../../config/config.yml'))
      unless @config['supported_models'].values.include?(status[:model])
        raise UnsupportedModel
      end
    end

    def switch_to(source)
      real_source = @config['sources'][source] or raise UnknownSource
      cmds = ["PutZone_InputFunction/#{real_source}"]
      path = @config['paths']['main_zone']
      request(path, cmds)
    end

    def set_volume_to(db)
      raise VolumeTooHigh if db.to_f > Marantz.config.max_volume
      path = @config['paths']['main_zone']
      request(path, @config['commands']['volume'] % db_to_volume(db))
    end

    def mute
      toggle_mute(:on)
    end

    def unmute
      toggle_mute(:off)
    end

    def on
      toggle_power(:on)
    end

    def off
      toggle_power(:off)
    end

    def status
      uri = URI(Marantz.config.endpoint + @config['paths']['status'])
      uri.query = URI.encode_www_form({ _: Time.now.to_i * 1_000 })
      response = Net::HTTP.get(uri)
      parser = XML::Parser.string(response, encoding: XML::Encoding::UTF_8)
      doc = parser.parse
      {
        power: doc.find('//Power').first.content,
        source: @config['sources'].key(doc.find('//NetFuncSelect').first.content) || :unknown,
        volume: volume_to_db(doc.find('//MasterVolume').first.content),
        model: @config['supported_models'][doc.find('//ModelId').first.content.to_i]
      }
    end

  private

    def toggle_mute(action)
      path = @config['paths']['main_zone']
      request(path, @config['commands']['mute'] % action.downcase)
    end

    def toggle_power(action)
      path = @config['paths']['main_zone']
      request(path, @config['commands']['power'] % action.upcase)
    end

    def db_to_volume(db)
      (VOLUME_THRESHOLD - db.to_f)
    end

    def volume_to_db(volume)
      (VOLUME_THRESHOLD + volume.to_f)
    end

    def request(path, commands)
      commands = ([commands].flatten << 'aspMainZone_WebUpdateStatus')
      params = {}.tap do |hash|
        commands.map.with_index { |c, i| hash["cmd#{i}"] = c }
      end
      uri = URI(Marantz.config.endpoint + path)
      result = Net::HTTP.post_form(uri, params)
    end
  end
end
