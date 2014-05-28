require 'sinatra/base'


module MiniWiki
  class App < Sinatra::Base

    configure do
      markdown_path = ARGV[0] || 'wiki'
      rootdir = File.basename(markdown_path)
      capitalized = rootdir[0].capitalize + rootdir[1..-1]
      set :app_markdown_path, '/' + rootdir
      set :app_page_header, capitalized
      set :app_pages_path, '/miniwikipages'
      set :app_code_path, '/miniwikicode'
      set :app_css_path, '/miniwiki.css'
      set :app_js_path, '/miniwiki.js'
      set :public_folder, markdown_path
    end

    helpers do
      def pages_list
        md_header =
          "\n\n**[Pages](#{settings.app_pages_path}):**\n\n"
        tree = Dir[settings.public_folder + '/**/*.md']
        "\n\n" + md_header + tree.inject("") do |result, line|
          p = line.sub(/#{settings.public_folder}/,
                       '').sub(/\.(md|markdown)$/, '')
          link_info = File.dirname(p).gsub(/^\//, '').split('/').reverse
            .join(' < ') .gsub(/-/, ' ').split(' ').map(&:capitalize)
            .join(' ')
          link_info = " - *#{link_info}*" if !link_info.empty?
          link_text = File.basename(p).gsub(/-/, ' ')
            .split.map(&:capitalize).join(' ')
          result + '- [' + link_text + '](' +
            settings.app_markdown_path + p + ')' + link_info + "\n"
        end + "\n\n"
      end

      def md_line() "\n\n--------\n\n" end

      def page(content)
        <<-PAGE
<!DOCTYPE html>
<html>
  <head>
    <title>MiniWiki</title>
    <link rel="stylesheet" href="#{settings.app_css_path}" type="text/css"\
 />
    <meta charset="utf-8"/>
  </head>
  <body class="">
    <div class="container">
    <div class="row">
      <div class="col-md-8">
#{content}
      </div>
      </br>
      <div id="pages-sidebar" class="col-md-3 col-md-offset-1 well">
      <input id="pages-search-box" class="form-control" type="text" \
placeholder="Search (RegEx supported)"/></br>
#{markdown(pages_list)}
      </div>
    </div>
    </div>
    <script type="text/javascript" src="#{settings.app_js_path}"></script>
  </body>
</html>
PAGE
      end

      def page_header(*args)
        text = args[0] || ''
        text = ' | ' + text if !text.empty?
        "# [#{settings.app_page_header}](/)" + text +
          "\n\n--------\n\n"
      end
    end

    get '/' do
      message = <<-MESSAGE

## Fun Fact

MiniWiki is a minimal Markdown-based Wiki. It is built using Sinatra. All
code lives in
[one small file](#{settings.app_code_path + '#one-small-file'})
.

--------

MESSAGE
      info_text = <<-INFOTEXT
## Quick Start

1. Put all your `.md` files in a directory (subdirs allowed), then run

        miniwiki [directory] [port]

   This requires
[rerun](https://github.com/alexch/rerun)
(`gem install rerun`).

2. Edit all your `.md` files with your favorite text editor. MiniWiki
automatically reloads them on changes.

3. If you put it on a server and do not want it to restart on file changes,
   simply run

        miniwiki-server [directory] [port]
4. If you link to a `.md` file from another `.md` file, specify the whole
path relative to the root directory where all your `.md` files live.
**Include the common root directory** in the path, but **leave out the
`.md` file extension**. Example (suppose this is in
`/rootdir/path/to/a/md/file`)

        [Link Text](/rootdir/path/to/another/md/file)

5. When including images or linking to other static files (.pdf, .mp3,
.avi, ...) in the Markdown directory, specify the whole path relative to
the root directory where all your `.md` files live, but **do not include
the common root directory** Also, **do not leave out the file extension**.
Example (suppose this is in `/rootdir/path/to/a/md/file`)

        ![Image Text](/path/to/an/image.png)

6. Find your pages in the sidebar.

## Installation

You already have MiniWiki, but in case you want to help a friend be more
productive:

        gem install miniwiki

INFOTEXT
      page(markdown(page_header +
                    info_text + message))
    end

    get %r{#{settings.app_markdown_path}/(.*)} do |path|
      page(markdown(page_header(File.basename(path)
                                  .gsub('-', ' ').split.map(&:capitalize)
                                  .join(' ')) +
                    File.read(settings.public_folder + '/' + path +
                              '.md')))
    end

    get settings.app_pages_path do
      page(markdown page_header + pages_list)
    end

    get settings.app_code_path do
      file_content = File.read(__FILE__, 'r')
      message = "This page shows the actual souce code of this particular \
MiniWiki installation.\n\n"
      code = "\n\n<h2 id=\"one-small-file\">One Small File</h2>" +
        message + file_content.split("\n").inject('') do |result, line|
        result + '        ' + line + "\n"
      end
      page(markdown(page_header('MiniWiki Code') + code))
    end

    get settings.app_css_path do
      content_type 'text/css'
      send_file File.dirname(__FILE__) +
        '/assets/stylesheets/bootstrap.min.css'
    end

    get settings.app_js_path do
      content_type 'text/javascript'
      pwd = File.dirname(__FILE__)
      jquery = File.read(pwd + '/assets/javascripts/jquery-1.11.0.min.js')
      app = File.read(pwd + '/assets/javascripts/app.js')
      jquery + "\n" + app
    end
  end
end


require 'rack'
app = Rack::Builder.new do
  run MiniWiki::App
end
Rack::Handler::WEBrick.run app, :Port => ARGV[1] || 3033
