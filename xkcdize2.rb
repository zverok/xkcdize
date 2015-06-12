#!/usr/bin/env ruby
# encoding: utf-8
require 'bundler/setup'
require 'rmagick'
require_relative 'rmagick_patch'

include Magick

# Source of algo http://blog.wolfram.com/2012/10/05/automating-xkcd-diagrams-transforming-serious-to-funny/
def xkcdize(src, shift=20)
  # Construct 2 "distorsion maps", separate for x and y shift of each pixel
  # Algorithm of construction:
  #   1. make image of random gray points, same size as source image
  #   2. apply the Gaussian blur to it, to make all transitions smooth
  #
  # Coefficients for Gaussian is from Vitaliy's post (second one is a
  # sigma value, which has default value of 5 in Wolfram Language)
  #
  distorters = 2.times.map{
    Image.random(src.columns, src.rows).adaptive_blur(10, 5)
  }

  # Trying to replace "fx" version with pure ruby.
  # It's clean, yet result is unacceptable
  src.zip(*distorters).map_to_image{|(s, dx, dy), col, row|
    src.pixel_color_f(col+shift*(0.5-dx.to_f), row+shift*(0.5-dy.to_f))
  }
end

fname = ARGV.shift
unless fname && File.exists?(fname)
  puts "No filename provided, usage: `#{__FILE__} <imagepath>`"
  exit 1
end
outname = fname.sub(/(\.[^.]+)$/, '-xkcd2\1')

start = Time.now

xkcdize(Image.read(fname).first).write(outname)

puts "%s => %s: %.2f seconds" % [fname, outname, Time.now-start]
