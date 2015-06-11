This is a small experimental script to play with Ruby and images.

It just takes some image and converts makes it "[xkcd](http://xkcd.com/)-like" (effect of
handwritedness).

Before: <img src="https://raw.github.com/zverok/xkcdize/master/image.png">
After: <img src="https://raw.github.com/zverok/xkcdize/master/image-xkcd.png">

The story behind the script is simple. I've just read an excellent blog 
[post](http://blog.wolfram.com/2012/10/05/automating-xkcd-diagrams-transforming-serious-to-funny/)
by Wolfram guy Vitaliy Kaurov, where he explains, how can you have
xkcd-style charts in Wolfram Mathematica. Most of ideas there are fairly
straighforward (set bold style for lines, add labels, use appropriate fonts),
but there was some image distortion idea, which makes any graphics look
"pencil-drawn".

And there, I've just thinking "Ruby **is** the best language evaaar, if
I can do the same thing, reproduce this beautiful algo, with the same
laconizm and elegance.

Look for yourself, if I could!

Wolfram version:

<img src="https://raw.github.com/zverok/xkcdize/master/xkcd-distort-wolfram.png">

Ruby version:

```ruby
def xkcdize(src)
  distorters = 2.times.map{
    Image.random(src.columns, src.rows).adaptive_blur(10, 5)
  }

  src.fx('p{i+15*(0.5-u[1]),j+15*(0.5-u[2])}', *distorters)
end
```

The algo is the same. Look at commented code into [xkcdize.rb](https://github.com/zverok/xkcdize/xkcdize.rb)

To be fair, the solution was not easy. The ImageMagick fx-script (which
is passed to `Image#fx` method) was hard to guess, and it's not a Ruby,
just a bit of RMagick internal script inside mine.

Yet it is all still pretty clean and laconic.