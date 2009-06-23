#!/usr/local/bin/ruby
#
# QRcode image library 0.50beta6  (c)2002-2004 Y.Swetake
#
#

require "GD"
require "qrcode.rb"

class Qrcode_image < Qrcode

def initialize
       super
       @module_size=4
       @quiet_zone=4
end

def set_module_size(z)
        if (z>0 && z<9) then
            @module_size=z
        end    
end

def set_quiet_zone(z)
        if (z>0 && z<9) then
            @quiet_zone=z
        end
end


def qrcode_image_out(org_data,image_type='png',filename='')
    image_out(make_qrcode(org_data) ,image_type,filename)
end


def image_out(data,image_type='png',filename='')

    if image_type=='jpeg' then
        if (filename.empty?) then
            mkimage(data).jpeg(STDOUT,95)
        else
            out=open(filename,"w")
            mkimage(data).jpeg(out,95)
            out.close
        end
    else
        if (filename.empty?) then
            mkimage(data).png STDOUT
        else
            out=open(filename,"w")
            mkimage(data).png(out)
            out.close
        end
    end
end

def mkimage(data)

        data_array=data.split("\n")
        image_size=data_array.size

        output_size=(image_size+@quiet_zone * 2) * @module_size

        img = GD::Image.new(image_size,image_size)

        white = img.colorAllocate (255, 255, 255)
        black = img.colorAllocate (0, 0, 0)

        im= GD::Image.new(output_size,output_size)
        white2 = im.colorAllocate (255,255,255)
        im.fill(0,0,white2)

        y=0

        data_array.each{|row|
           x=0
           while x<image_size
               if (row[x,1]=="1") then
                   img.setPixel(x,y,black)
               end
               x+=1
           end
        y+=1
        }

        quiet_zone_offset= @quiet_zone * @module_size
        image_width=image_size * @module_size

        img.copyResized(im,quiet_zone_offset ,quiet_zone_offset,0,0,image_width ,image_width ,image_size,image_size)

        return(im)
    end
end


