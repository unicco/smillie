#!/usr/local/bin/ruby
#
# QRcode library sample for Ruby
#
# This sample program makes a QRcode image from STDIN.
#
# This program requires Ruby-GD.
#
#Usage 
#
# ./sample0.rb > out.png
#
# data.txt : data file
# out.png  : qrcode png image file
#
# version     :auto
# ecc level   :M
# module size :4
# quiet zone  :4
#

require "./qrcode_img.rb"

d="01234567"
if d.length == 0 then
 print "no data\n"
 exit
end

x=Qrcode_image.new
#x.image_out(x.make_qrcode(d),"png")  # -- old style
x.qrcode_image_out(d,'png')
