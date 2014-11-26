require 'uri'
require 'net/http'
require 'net/https'
require 'json'
require 'date'
require 'erb'

username = ARGV[0] || 'bethesque'
last_run_time_string = ARGV[1] || "2014-09-04T08:31:46Z"
last_run_time_file_location = "/tmp/gist-notifications-last-run-time"
#last_run_time_string = "2013-09-04T08:31:46Z"

class RunDetails

  attr_reader :username

  def initialize username, last_run_time_file_location
    @this_run_time = DateTime.now
    @username = username
    @last_run_time_file_location = last_run_time_file_location
  end

  def last_run_time
    @last_run_time ||= begin
      if File.exist?(last_run_time_file_location)
        DateTime.parse(File.read(last_run_time_file_location))
      else
        DateTime.now - 1
      end
    end
  end

  def update_last_run_time
    File.open(last_run_time_file_location, "w") { |file| file << this_run_time.xmlschema }
  end

  private

  attr_reader :last_run_time_file_location, :this_run_time

end

class GistRepository

  def gists_with_comments_updated_since username, last_run_time
    get_gists_with_comments(username)
      .select{ | gist | gist.any_comments_created_or_updated_since? last_run_time }
  end

  private

  def make_request url
    puts url
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    request['Accept'] = 'application/vnd.github.v3+json'
    response = http.request(request)
    if response.code == '200'
      JSON.parse(response.body)
    else
      raise "Error response #{response.code} #{response.body}"
    end
  end

  def get_gists_for_user username
    make_request("https://api.github.com/users/#{username}/gists")
      .collect { |gist| Gist.new(gist) }
  end

  def add_comments gists
    gists.select(&:has_comments?).collect do | gist |
      sleep 3
      gist.comments = get_comments(gist)
      gist
    end
  end

  def get_gists_with_comments username
    add_comments(get_gists_for_user(username))
  end


  def get_comments gist
    make_request gist.comments_url
  end
end


class Gist

  def initialize attributes
    @attributes = attributes
    @comments = []
  end

  def description
    attributes["description"]
  end

  def comments_url
    attributes['comments_url']
  end

  def has_comments?
    attributes["comments"] > 0
  end

  def comments= comments
    @comments = comments
  end

  def to_json options = {}
    to_hash.to_json options
  end

  def to_hash
    {
      "url" => attributes["url"],
      "description" => attributes["description"],
      "comments" => comments
    }
  end

  def any_comments_created_or_updated_since? datetime
    comments_created_or_updated_since(datetime).any?
  end

  def comments_created_or_updated_since datetime
    comments.select do | comment |
      # puts "checking #{DateTime.parse(comment["updated_at"])} >= #{datetime} #{DateTime.parse(comment["updated_at"]) >= datetime}"
      DateTime.parse(comment["updated_at"]) >= datetime
    end
  end

  private

  attr_reader :attributes, :comments

end

run_details = RunDetails.new(username, last_run_time_file_location)
gists = GistRepository.new.gists_with_comments_updated_since(run_details.username, run_details.last_run_time)
run_details.update_last_run_time
puts "#{gists.size} updated since #{run_details.last_run_time}"
renderer = ERB.new(DATA.read)
puts renderer.result(binding())


__END__
<% gists.each do | gist | %>
  <%= gist.description %>
    <% gist.comments_created_or_updated_since(run_details.last_run_time).each do | comment | %>
      <%= comment['user']['login'] %> said:
      <%= comment['body'] %>
      <%= comment['url'] %>
    <% end %>
<% end %>
