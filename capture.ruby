require 'nokogiri'
require 'open-uri'
require 'natto'

def onLoad(url)
  nm = Natto::MeCab.new
  doc = Nokogiri::HTML(open(url)) do |config|
    config.noblanks
  end

  doc.search("script").each do |script|
    script.content = ""
  end

  doc.css('body').each do |elm|
    text = elm.content.gsub(/(\t|\s|\n|\r|\f|\v)/,"")
    nm.parse(text) do |n|
      if n.surface =~ /^[\w|\W|\s]$/ ||
        n.surface =~ /^[0-9]+$/ ||
        n.surface =~ /^[、。，．・：；？！゛゜´｀¨＾￣＿ヽヾゝ]$/
        next
      end
      puts n.surface
    end
  end
end

ret = false
ret1 = false

while 1
  ret = `osascript -l JavaScript -e 'Application("Google Chrome").windows.at(0).activeTab().loading()'`
  if ret.gsub(/\n/, "") == "true"
    ret = true
  else
    ret = false
  end

  if ret1 && !ret then
    url = `osascript -l JavaScript -e 'Application("Google Chrome").windows.at(0).activeTab().url()'`.gsub(/\n/, "")
    if url == "chrome://newtab/"
      ret1 = false
    else
      begin
        onLoad(url)
      rescue
        next
      end
      ret1 = false
    end
  end
  sleep(0.2)
  if ret then
    begin
      ret1 = true
    end while !ret
  end
end
