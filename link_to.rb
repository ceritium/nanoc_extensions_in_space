module Nanoc::Helpers

  # Nanoc::Helpers::LinkTo contains functions for linking to pages.
  #
  # To activate this helper, +include+ it, like this:
  #
  #   include Nanoc::Helpers::LinkTo
  module LinkTo

    require 'nanoc/helpers/html_escape'
    include Nanoc::Helpers::HTMLEscape


    #  Returns the path of a page given its page_id (its "name")
    # 
    # Usage:
    # in your ERB-enabled layout or content, use: <a href="<%= path_for :home %>">Home</a>
    # 
    # You can use a symbol or a string for your page name. Strings are nice for pages in subfolders:
    # 
    # <a href="<%= path_for "blog/2008/post_name" %>">A nice post</a>
    def path_for page_id
      # Find page
      target_page = @pages.select { |page| page.path.gsub(/^\//,"").gsub(/\/$/,"").gsub(".#{page.extension}","") == page_id.to_s }.first
      if target_page.nil?
        return page_id
      else
        return target_page.path
      end
    end  
    

    # Creates a HTML link to the given path or page/asset representation, and
    # with the given text.
    #
    # +path_or_rep+:: the URL or path (a String) that should be linked to, or
    #                 the page or asset representation that should be linked
    #                 to.
    #
    # +text+:: the visible link text.
    #
    # +attributes+:: a hash containing HTML attributes that will be added to
    #                the link.
    #
    # Examples:
    #
    #   link_to('Blog', '/blog/')
    #   # => '<a href="/blog/">Blog</a>'
    #
    #   page_rep = @pages.find { |p| p.page_id == 'special' }.reps(:default)
    #   link_to('Special Page', page_rep)
    #   # => '<a href="/special_page/">Special Page</a>'
    #
    #   link_to('Blog', '/blog/', :title => 'My super cool blog')
    #   # => '<a href="/blog/" title="My super cool blog">Blog</a>
    def link_to(text, path_or_rep=nil, attributes={})
      
      path_or_rep = path_or_rep.to_s
      # Find path
      path = path_or_rep.is_a?(String) ? path_for(path_or_rep) : path_or_rep.to_s.path
      
      # Join attributes
      attributes = attributes.inject('') do |memo, (key, value)|
        memo + key.to_s + '="' + h(value) + '" '
      end

      # Create link
      "<a #{attributes}href=\"#{path}\">#{text}</a>"
    end


    def oh_path(path_or_rep)
      path = path_or_rep.is_a?(String) ? path_for(path_or_rep) : path_or_rep.path
    end

    # Creates a HTML link using link_to, except when the linked page is the
    # current one. In this case, a span element with class "active" and with
    # the given text will be returned.
    #
    # Examples:
    #
    #   link_to_unless_current('Blog', '/blog/')
    #   # => '<a href="/blog/">Blog</a>'
    #
    #   link_to_unless_current('This Page', @page_rep)
    #   # => '<span class="active">This Page</span>'
    def link_to_unless_current(text, path_or_rep=nil, attributes={})
      path_or_rep = path_or_rep.to_s
      
      # Find path
      path = path_or_rep.is_a?(String) ? path_for(path_or_rep) : path_or_rep.path
      
      if @page_rep and @page_rep.path == path
        # Create message
        "<span class='active' title='#{attributes[:title].nil? ? 'Estas aquí' : attributes[:title]}'>#{text}</span>"
      else
        link_to(text, path_or_rep, attributes)
      end
    end

    # Returns the relative path from the current page to the given path or
    # page/asset representation.
    #
    # +path_or_rep+:: the URL or path (a String) to where the relative should
    #                 point, or the page or asset representation to which the
    #                 relative should point.
    #
    # Example:
    #
    #   # if the current item's path is /foo/bar/
    #   relative_path('/foo/qux/')
    #   # => '../qux/'
    def relative_path_to(path_or_rep)
      require 'pathname'

      # Find path
      path = path_or_rep.is_a?(String) ? path_or_rep : path_or_rep.path

      # Get source and destination paths
      dst_path   = Pathname.new(path)
      src_path   = Pathname.new((@page || @asset).path)

      # Calculate relative path (method depends on whether destination is a
      # directory or not).
      if src_path.to_s[-1,1] != '/'
        relative_path = dst_path.relative_path_from(src_path.dirname).to_s
      else
        relative_path = dst_path.relative_path_from(src_path).to_s
      end

      # Add trailing slash if necessary
      if dst_path.to_s[-1,1] == '/'
        relative_path += '/'
      end

      # Done
      relative_path
    end

  end

end
