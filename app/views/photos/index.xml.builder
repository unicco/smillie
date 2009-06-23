xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.photos :party => @party.key, :post_address => @party.mail_addr, :post_qrcode => "http://#{request.host_with_port}#{@party.qrcode_path}" do
  @photos.each do |photo|
    xml.photo :id => photo.id, :link => "http://#{request.host_with_port}/photos/#{@party.key}/#{photo.filename}", :date => photo.created_at.xmlschema
  end
end
