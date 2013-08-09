module WillPaginate
  module ActiveRecord
    module RelationMethods
      #alias_method :per, :per_page
      #alias_method :num_pages, :total_pages
      #alias_method :total_count, :count
    end
  end

  module ActionView
    #def will_paginate(collection = nil, options = {})
    #  options[:inner_window] ||= 0
    #  options[:outer_window] ||= 0
    #  options[:class] ||= 'pagination pull-left'

    #  options[:renderer] ||= BootstrapLinkRenderer
    #  super.try :html_safe
    #end

    #class BootstrapLinkRenderer < LinkRenderer
    #  protected

    #  def html_container(html)
    #    tag :div, tag(:ul, html), container_attributes
    #  end

    #  def page_number(page)
    #    tag :li, link(page, page, :rel => rel_value(page)), :class => ('active' if page == current_page)
    #  end

    #  def previous_or_next_page(page, text, classname)
    #    tag :li, link(text, page || 'javascript:void(0)'), :class => [classname[0..3], classname, ('disabled' unless page)].join(' ')
    #  end

    #  def gap
    #    tag :li, link(super, 'javascript:void(0)'), :class => 'disabled'
    #  end

    #end
  end
end
