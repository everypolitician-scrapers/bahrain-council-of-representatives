#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('div.list ul .PersonalBox_Container').each do |li|
    data = { 
      id: li.attr('id'),
      name: li.css('.PersonalBox_text_Name').text.tidy,
      image: li.css('img.MemberImg/@src').text,
      source: li.css('.PersonalBox_text a/@href').text,
      term: 2014,
    }
    %i(image source).each { |i| data[i] = URI.join(url, URI.encode(data[i])).to_s unless data[i].to_s.empty? }
    ScraperWiki.save_sqlite([:id, :term], data)
  end
end

scrape_list('http://www.nuwab.gov.bh/CouncilMembers/Pages/default.aspx')
