#!/usr/bin/env ruby
# encoding: utf-8
require 'bundler/setup'
require 'rmagick'
require_relative 'rmagick_patch'

include Magick

# Source of algo http://blog.wolfram.com/2012/10/05/automating-xkcd-diagrams-transforming-serious-to-funny/
def xkcdize(src)
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

  # The ImageMagick "fx" script we are using is a bit tricky.
  #
  # Read it like this:
  # * script is performed to define each pixel of resulting image
  # * it is done by reading pixel value (p function) of current pixel
  # * ...which is shifted relative to current column (i)
  #   by ± 7 pixels. u[1] here is "value" (0..1) of current pixel in
  #   second image -- grayscale and blurred
  # * the same is for row -- j is current row and u[2] is third image
  #   current pixel
  #
  # So, the shift of each pixel is a) random b) not more than ±7 by each
  # axis, and c) smooth comparing to neighbour pixels
  #
  src.fx('p{i+15*(0.5-u[1]),j+15*(0.5-u[2])}', *distorters)
end

fname = ARGV.shift
unless fname && File.exists?(fname)
  puts "No filename provided, usage: `#{__FILE__} <imagepath>`"
  exit 1
end
outname = fname.sub(/(\.[^.]+)$/, '-xkcd\1')

start = Time.now

xkcdize(Image.read(fname).first).write(outname)

puts "%s => %s: %.2f seconds" % [fname, outname, Time.now-start]
