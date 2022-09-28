require 'jekyll'

module Jekyll
  class Figurify < Jekyll::Generator

    ICONS = {
      "agenda" => "",
      "code-in" => "far fa-keyboard",
      "code-out" => "fas fa-laptop-code",
      "comment" => "far fa-comment-dots",
      "details" => "fas fa-info-circle",
      "feedback" => "far fa-comments",
      "hands-on" => "fas fa-pencil-alt",
      "hidden" => "",
      "matrix" => "",
      "overview" => "",
      "question" => "far fa-question-circle",
      "quote" => "",
      "solution" => "far fa-eye",
      "spoken" => "",
      "tip" => "far fa-lightbulb",
      "warning" => "fas fa-exclamation-triangle",
    }

    BOX_TITLES = {
      "agenda" => "Agenda",
      "code-in" => "Input",
      "code-out" => "Output",
      "comment" => "Comment",
      "details" => "Details",
      "hands-on" => "Hands-on",
      "question" => "Question",
      "solution" => "Solution",
      "tip" => "Tip",
      "warning" => "Warning",
    }

    COLLAPSIBLE_BOXES = [
      "hands-on", "details", "question", "solution", "tip",
    ]

    BOX_CLASSES = ICONS.keys.join "|"
    TITLE_CLASSES = ICONS.keys.map{|x| "#{x}-title" }.join "|"

    def initialize(config)
      @config = config['boxify'] ||= {}
    end

    def generate(site)
      site.pages
        .select { |page| not skip_layout? page.data['layout'] }
        .each { |page| boxify page,site }
      site.posts.docs
        .select { |post| not skip_layout? post.data['layout'] }
        .each { |post| boxify post, site }
    end

    def get_icon(icon)
       if icon.start_with?("fa")
        %Q(<i class="#{icon}" aria-hidden="true"></i><span class="visually-hidden">#{@text}</span>)
       elsif icon.start_with?("ai")
        %Q(<i class="ai #{icon}" aria-hidden="true"></i><span class="visually-hidden">#{@text}</span>)
       end
    end

    def generate_collapsible_title(box_type, count, title)
      title_fmted = (title ? ": #{title}" : "")
      return %Q(
        <div class="box-title">
        <button type="button" aria-controls="box-#{box_type}-#{count}" aria-expanded="true" aria-label="Toggle #{box_type} box: #{title}">
          #{get_icon(ICONS[box_type])} #{BOX_TITLES[box_type]}#{title_fmted}
          <span role="button" class="fold-unfold fa fa-plus-square"></span>
        </button>
        </div>
      ).split(/\n/).map{|x| x.lstrip.rstrip}.join("").lstrip.rstrip
    end

    def generate_static_title(box_type, count, title)
      title_fmted = (title ? ": #{title}" : "")
      return %Q(
        <div class="box-title" aria-label="#{box_type} box: #{title}">
          #{get_icon(ICONS[box_type])} #{BOX_TITLES[box_type]}#{title_fmted}
        </div>
      ).split(/\n/).map{|x| x.lstrip.rstrip}.join("").lstrip.rstrip
    end

    def generate_title(box_type, count, title)
      if COLLAPSIBLE_BOXES.include?(box_type)
        generate_collapsible_title(box_type, count, title)
      else
        generate_static_title(box_type, count, title)
      end
    end

    def generate_box(box_type, count, title)
      box_title = generate_title(box_type, count, title)
      return %Q(
        <div class="box #{box_type}" markdown=0>
        #{box_title}
        <div id="box-#{box_type}-#{count}" class="box-content" markdown=1>
      ).split(/\n/).map{|x| x.lstrip.rstrip}.join("").lstrip.rstrip
    end

    def boxify(page, site)
      if page.content.nil?
        return
      end
      count = 0

      # Interim solution, fancier box titles
      page.content = page.content.gsub(/<(#{TITLE_CLASSES})>([^<]*)<\/\s*\1>/) {
        box_type = $1
        count += 1
        box = generate_title(box_type, count, nil)
        puts "BOX #{box}"
        box
      }

      # Long term solution, proper new boxes
      page.content = page.content.gsub(/<(#{CLASSES})>/) {
        box_type = $1
        box = generate_box(box_type, 0, nil)
        puts "BOX #{box}"
        box
      }

      page.content = page.content.gsub(/<(#{CLASSES}) title="([^"]*)">/) {
        box_type = $1
        title = $2
        count += 1
        box = generate_box(box_type, count, title)
        puts "BOX #{box}"
        box
      }

      page.content = page.content.gsub(/<\/\s*(#{CLASSES})\s*>/) {
        box_type = $1
        "\n</div></div><!--#{box_type}-->"
      }
    end
  end
end
