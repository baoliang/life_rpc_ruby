#!/usr/bin/ruby
#encoding: utf-8
require "anemone"
require "uri"
require "./models/move.rb"
require "./models/lianxuju.rb"
require "./models/gridfs.rb"
require "open-uri"


#转码
String.class_eval do 
  def to_utf8
    self.encode!("utf-8", :undef => :replace, :replace => "?", :invalid => :replace)
  end
end

def get_m_info(page)
  name  = ""
  director = ""         
  actor = ""
  status = ""
  label = ""
  desc = ""
  pic = ""
  type = "" 
  lab = nil
  if page.doc.at("body").inner_html.include? '<div id="zkb">'
    page.doc.search("//div[@id='zkb']").each do |div|
      name = div.search("h1")[0].text
      director =  div.search("li").search("a")[0].text
      div.search("li")[1].search("a").each do |a|
        actor << ", #{a.text}"
      end
      status = div.search("li")[2].search("span")[0].text
      pic =   page.doc.search("//div[@id='zka']").search("img")[0]["src"]
      label =  div.search("li")[3].text
      desc  = div.search("li")[4].text
      data=open("http://www.kan520.com#{pic}"){|f|f.read}
      Gridfs.new.save_file(pic, data)
      

   

      move = Move.where("name LIKE '%#{name}%'").first()
      if label.include?("电视剧") 
        if not move
          move = Move.new(:lab=>lab, :name=> name,:types=> "1",:actor=>actor, :status=>status, :label=> label, :pic=> pic, :director=>director,  :desc=>desc)
          move.save()
         
        end
      else
        if not move
          move = Move.new(:lab=>lab, :name=> name,:types=>"0",:actor=>actor, :status=>status, :label=> label, :pic=> pic, :director=>director,  :desc=>desc)
          move.save()
        else
          if move.label == nil                             
            move.name = name
            move.types = "0"
            move.actor = actor
            move.status = status
            move.label = label
            move.pic = pic
            move.lab = lab
            move.director = director 
            move.desc = desc
            move.save()
            
          end

        end
      end
     
    end

  end  
end

def get_detail_info(page)
  if page.doc.at("body").inner_html.include?('<span id="loadplay">')
    name = ""
    url  = ""
    desc = ""
    name = page.doc.at("title").inner_html.encode!("utf-8", :undef => :replace, :replace => "?", :invalid => :replace)
    page.doc.css("div.juqing").each do |node|
      desc = node.inner_html.encode!("utf-8", :undef => :replace, :replace => "?", :invalid => :replace)
    end  
    page.doc.xpath("//script").each do |script|
      if script.inner_html.include? "unescape"
        url = URI.unescape(script.inner_html.slice(/\('.+\)/)).slice(/'.+'/)
        
      end
      
    end
    
    move_name = name.slice /《.+》/

    move_name = move_name.gsub "《", ""
    move_name = move_name.gsub "》", ""
    move = Move.where("name LIKE '%#{move_name}'").first()
    lianxuju = Lianxuju.where(:name=> name).first()
    p move_name
    if name.slice /第.+集/
      if not lianxuju
        lianxuju = Lianxuju.new(:name=>name, :url=>url) 
        lianxuju.save()
      else
        if url  != lianxuju.url
          lianxuju.url = url
          lianxuju.save()
        end
      end
    else
      if not move
          move = Move.new(:name=> name, :url=>url, :desc=>desc)
          move.save()
      else
          move.url = url
          move.save()  
      end
    end  
  end
end

Anemone.crawl('url') do |anemone|
  anemone.storage = Anemone::Storage.MongoDB
  anemone.on_every_page do |page|
    begin
      if page.url.host == 'www.kan520.com'
        get_m_info(page)
        get_detail_info(page) 
        
      end 
    rescue => err
      p err
    end
  end
end
