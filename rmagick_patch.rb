# encoding: utf-8
class Magick::Image
  def self.random(columns, rows)
    Image.constitute(columns, rows, 'I', (columns*rows).times.map{rand}){
      self.colorspace = GRAYColorspace
    }
  end

  def fx(script, *others)
    list = ImageList.new
    list << self
    others.each{|i| list << i}
    list.fx(script)
  end
end

