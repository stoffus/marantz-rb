require 'xml'

module Marantz
  class Client
    def initialize
      raise UnsupportedModel unless SUPPORTED_MODELS.values.include?(status[:model])
    end

    def source=(name)
      perform(PATHS[:main_zone], COMMANDS[:source] % (SOURCES[name] or raise UnknownSource))
    end

    def source
      status[:source]
    end

    def volume=(db)
      db = db.to_f
      raise VolumeTooHigh if db > Marantz.config.max_volume
      path = PATHS[:main_zone]
      perform(path, COMMANDS[:volume] % db_to_volume(db))
    end

    def preset=(ch)
      # PutNetAudioCommand/PresetCall03
      channel = "PresetCall0#{ch}"
      path = PATHS[:main_zone]
      perform(path, COMMANDS[:preset] % channel)
    end

    def volume
      status[:volume]
    end

    def power
      status[:power]
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

  private

    def toggle_mute(action)
      perform(PATHS[:main_zone], COMMANDS[:mute] % action.downcase)
    end

    def toggle_power(action)
      perform(PATHS[:main_zone], COMMANDS[:power] % action.upcase)
    end

    def db_to_volume(db)
      (VOLUME_THRESHOLD - db.to_f)
    end

    def volume_to_db(volume)
      (VOLUME_THRESHOLD + volume.to_f)
    end

    def status
      uri = URI('http://' + Marantz.config.host + PATHS[:status])
      uri.query = URI.encode_www_form({ _: Time.now.to_i * 1_000 })
      response = Net::HTTP.get(uri)
      parser = XML::Parser.string(response, encoding: XML::Encoding::UTF_8)
      doc = parser.parse
      result =     {
        power: doc.find('//Power').first.content,
        #source: SOURCES.key(doc.find('//NetFuncSelect').first.content) || :unknown,
        source: SOURCES.key(doc.find('//InputFuncSelectMain').first.content) || :unknown,
        volume: volume_to_db(doc.find('//MasterVolume').first.content),
        model: SUPPORTED_MODELS[doc.find('//ModelId').first.content.to_i]
      }
      result
    end

    def perform(path, commands)
      commands = ([commands].flatten << 'aspMainZone_WebUpdateStatus')
      params = {}.tap do |hash|
        commands.each.with_index { |c, i| hash["cmd#{i}"] = c }
      end
      uri = URI('http://' + Marantz.config.host + path)
      result = Net::HTTP.post_form(uri, params)
      result
    end
  end
end
