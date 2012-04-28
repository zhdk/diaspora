require 'uri'
class DiasporaConfig
  def self.method_missing(sym, *args, &block)
    ENV[sym.to_s]
  end

  def self.pod_uri
    @pod_uri ||= lambda do
      URI.parse(self.pod_url) 
    end.call
  end
end