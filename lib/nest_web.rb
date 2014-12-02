require 'excon'
require 'json'
require 'uri'

module NestWeb
  def self.login(email, password)
    response = Excon.post('https://home.nest.com/session', {
      body: JSON.dump(email: email, password: password),
      headers: {
        'Content-Type' => 'application/json',
        'User-Agent' => self.user_agent,
        'X-Requested-With' => 'XMLHttpRequest'
      },
      expects: [201]
    })
    data = JSON.parse(response.body)
    session = Session.new(
      token: data.fetch('access_token'),
      user_id: data.fetch('userid'),
      transport_url: data.fetch('urls').fetch('transport_url')
    )
  end

  def self.user_agent
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.71 Safari/537.36'
  end

  class Session
    attr_reader :token, :user_id, :transport_url

    def initialize(attributes = {})
      @token = attributes.fetch(:token)
      @user_id = attributes.fetch(:user_id)
      @transport_url = URI.parse(attributes.fetch(:transport_url))
    end

    def user
      User.new(self)
    end

    def structures
      user.structure_ids.map do |structure_id|
        Structure.new(self, structure_id)
      end
    end

    def data
      @data ||= begin
        response = Excon.get("#{self.transport_url}/v5/web/user.#{self.user_id}", {
          query: {'_' => Time.now.to_i * 1000},
          headers: headers
        })
        JSON.parse(response.body)
      end
    end

    def headers
      {
        'Host'                  => transport_url.host,
        'Origin'                => transport_url.to_s,
        'User-Agent'            => NestWeb.user_agent,
        'Authorization'         => "Basic #{token}",
        'Accept-Language'       => 'en-us',
        'Connection'            => 'keep-alive',
        'X-nl-protocol-version' => 1,
        'X-nl-webapp-version'   => 'SNAPSHOT',
        'X-Requested-With'      => 'XMLHttpRequest',
        'Accept'                => 'application/json, text/javascript, */*; q=0.01'
      }
    end
  end

  class User
    attr_reader :session

    def initialize(session)
      @session = session
    end

    def structure_ids
      dataum = session.data.fetch('objects').find do |datum|
        datum['object_key'] == "user.#{session.user_id}"
      end
      dataum.fetch('value').fetch('structures')
    end
  end

  class Structure
    attr_reader :session, :structure_id

    def initialize(session, structure_id)
      @session = session
      @structure_id = structure_id
    end

    def away_status
      away = object.fetch('value').fetch('away')
      away_setter = object.fetch('value').fetch('away_setter')
      case
      when away == true && away_setter == 0
        'away'
      when away == true && away_setter == 1
        'auto-away'
      when away == false
        'home'
      else
        raise 'Unknown value.'
      end
    end

    def set_away_status(new_away_status)
      value = {'away_timestamp' => Time.now.to_i}
      value = case new_away_status
      when 'home'
        value.merge!('away' => false)
      when 'away'
        value.merge!('away' => true, 'away_setter' => 0)
      when 'auto-away'
        value.merge!('away' => true, 'away_setter' => 1)
      else
        raise ArgumentError, 'Unknown value. Expected one of "home", "away" or "auto-away"'
      end
      response = Excon.post("#{session.transport_url}/v5/put", {
        body: JSON.dump({
          objects: [{
            base_object_revision: revision,
            object_key: key,
            op: 'MERGE',
            value: value
          }]
        }),
        headers: session.headers.merge('Content-Type' => 'application/json'),
        expects: [200]
      })
      object['value'].merge!(value)
    end

    def away_timestamp
      object.fetch('value').fetch('away_timestamp')
    end

    def revision
      object.fetch('object_revision')
    end

    def key
      object.fetch('object_key')
    end

    private

    def object
      session.data.fetch('objects').find do |dataum|
        dataum['object_key'] == structure_id
      end
    end
  end
end
