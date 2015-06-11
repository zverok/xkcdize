# encoding: utf-8
class RMagick::Image
  def self.random(columns, rows)
    Image.constitute(columns, rows, 'I', (columns*rows).map{rand}){
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

