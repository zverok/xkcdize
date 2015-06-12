# encoding: utf-8
module Interplolate
  module_function

  # See http://en.wikipedia.org/wiki/Bilinear_interpolation
  def bilinear(c, r, fq11, fq12, fq21, fq22)
    c1, c2 = c.floor, c.ceil
    r1, r2 = r.floor, r.ceil

    fr1 = fq11 * ((c2 - c) / (c2 - c1)) + fq21 * ((c - c1) / (c2 - c1))
    fr2 = fq12 * ((c2 - c) / (c2 - c1)) + fq22 * ((c - c1) / (c2 - c1))

    fr1 * ((r2 - r) / (r2 - r1)) + fr2 * ((r - r1) / (r2 - r1))
  end
end

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

  # pixel color with float coords
  # does bilinear interpolation of four pixels around coordinates
  def pixel_color_f(c, r)
    c1, c2 = c.floor, c.ceil
    r1, r2 = r.floor, r.ceil
    return pixel_color(c, r) if c1 == c2 && r1 == r2
    
    fq11 = pixel_color(c1, r1)
    fq12 = pixel_color(c1, r2)
    fq21 = pixel_color(c2, r1)
    fq22 = pixel_color(c2, r2)

    Pixel.new(
      Interplolate.bilinear(c, r, fq11.red, fq12.red, fq21.red, fq22.red),
      Interplolate.bilinear(c, r, fq11.green, fq12.green, fq21.green, fq22.green),
      Interplolate.bilinear(c, r, fq11.blue, fq12.blue, fq21.blue, fq22.blue),
    )
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
