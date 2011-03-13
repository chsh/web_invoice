
require 'optparse'
require 'web_invoice'

class WebInvoice::CLI
  class Params
    def initialize(args)
      opt = OptionParser.new
      opt.on('-c config-file', 'default: ~/.webinvoicerc') { |v| @config = YAML.load_file(v) }
      opt.on('-d download-dir','default: .' ) { |v| @download_to = v }
      opt.on('-s service', 'default: saison_card') { |v| @service_name = v }
      opt.on('-u user') { |v| @user = v }
      opt.on('-p password') { |v| @password = v }
      opt.parse! args
      @config ||= YAML.load_file(File.join(ENV['HOME'], '.webinvoicerc'))
      @service_name = lookup_master_service
      @service_config = symbolize_keys(@config['services'][@service_name])
      @service_config[:download_to] = @download_to if @download_to
      @service_config[:user] = @user if @user
      @service_config[:password] = @password if @password
    end
    attr_reader :service_name, :service_config
    def service_class
      begin
        eval "WebInvoice::#{service_name.split(/_/).map { |w| w.capitalize }.join('')}"
      rescue
        nil
      end
    end
    private
    def lookup_master_service
      @config['services'].each do |key, value|
        return key if value['default']
      end
      nil
    end
    def symbolize_keys(hash)
      return nil unless hash
      h = {}
      hash.each do |key, value|
        h[key.to_s.to_sym] = value
      end
      h
    end
  end
  def self.run(args)
    WebInvoice::CLI.new.run(args)
  end
  def run(args)
    params = Params.new(args)
    sc = params.service_class
    raise "service_class not found." unless sc
    sc.execute params.service_config
  end
end

WebInvoice::CLI.run(ARGV)
