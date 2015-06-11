# encoding: utf-8
class Magick::Image
  def self.random(columns, rows)
    Image.constitute(columns, rows, 'I', (columns*rows).times.map{rand}){
      self.colorspace = GRAYColorspace
    }
  end

  def fx(script, *others)
    self.zip(*others).fx(script)
  end

  def zip(*others)
    list = ImageList.new
    list << self
    others.each{|i| list << i}
    list
  end
end

class Magick::ImageList
  def map_to_image(&block)
    res = Magick::Image.new(first.columns, first.rows){self.background_color = 'white'}
    
    (0...first.columns).each do |c|
      (0...first.rows).each do |r|
        pixels = to_a.map{|i| i.pixel_color(c, r)}
        res.pixel_color(c, r, block.call(pixels, c, r))
      end
    end
    res
  end
end

class Magick::Pixel
  def to_f
    intensity.to_f / 65535
  end
end
