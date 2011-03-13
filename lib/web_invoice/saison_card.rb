# -*- encoding: utf-8 -*-

require 'rubygems'
require 'mechanize'

class WebInvoice::SaisonCard
  def initialize(opts = {})
    @agent = Mechanize.new
    @user_id = opts[:user]
    @user_password = opts[:password]
    @download_to = opts[:download_to] || '.'
  end
  def self.execute(opts)
    wi = new opts
    wi.login
    wi.download
  end
  def login
    do_login unless @login
  end
  def download(folder = nil)
    login
    folder ||= @download_to
    pwd = `pwd`.chomp
    if folder
      Dir.chdir folder
    end
    @agent.page.link_with(text: '利用明細確認').click
    csv_link = @agent.page.link_with(text: 'CSVダウンロード')
    pdf_link = @agent.page.link_with(text: 'Web明細ダウンロード')
    csv_link.click
    @agent.page.save
    pdf_link.click
    @agent.page.save
    if folder
      Dir.chdir pwd
    end
  end
  private
  def do_login
    @agent.get 'https://netanswerplus.saisoncard.co.jp/WebPc/welcomeSCR.do'
    f = @agent.page.forms[0]
    f.inputId = @user_id
    f.inputPassword = @user_password
    f.submit
    @login = true
  end
end
