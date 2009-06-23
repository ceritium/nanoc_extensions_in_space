# Generates an image tag always relative to the current page unless absolute path or http url specified.
# 
# img('test_image.gif')   ->   <img src="/images/test_image.gif" alt="Test image"/>
# img('contact/test_image.gif')   ->   <img src="/images/contact/test_image.gif" alt="Test image"/>
# img('http://localhost/test_image.gif')   ->   <img src="http://localhost/test_image.gif" alt="Test image"/>
def image_tag(name, options = {})
  options[:src] = get_rel(name.match(%r{^((\.\.?)?/|https?://)}) ? name : "/images/#{name}")
  options[:alt] ||= name.split('/').last.split('.').first.capitalize.gsub(/_|-/, ' ')
  tag :img, options
end


# Generates HTML tags:
#
# tag(:br)   ->   <br/>
# tag(:a, :href => 'test.html') { "Test" }    ->    <a href="test.html">Test</a>
#
def tag(name, options = {}, &block)
  options[:id] ||= options[:name] if options[:name]
  output = "<#{name}"
  options.keys.sort { |a, b| a.to_s <=> b.to_s }.each do |key|
    output << " #{key}=\"#{options[key]}\"" if options[key]
  end
  
  if block_given?
    output << ">"
    output << yield
    output << "</#{name}>"
  else
    output << "/>"
  end
  output
end



def link_to_back(text = 'Volver')
  link_to text, 'javascript:history.back();'
end