#use latest version of sinatra
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/vendor/sinatra/lib')

# isitblankyet.rb
require 'rubygems'
require 'sinatra'

not_found do
  headers["Status"] = "301 Moved Permanently"
  redirect("/")
end

helpers do
  def countdown_name
    if params[:name]
      @name = params[:name]
    else 
      if params[:hour]
        @name = "#{params[:year]}/#{params[:month]}/#{params[:day]} #{params[:hour]}:#{params[:minute]}"
      else
        @name = "#{params[:year]}/#{params[:month]}/#{params[:day]}"
      end
    end
  end
end

# === routes ===

# index, today
get '/' do
  t = Time.now
  uri = t.strftime("%Y/%m/%d/today")
  redirect(uri)
end

# date
get '/:year/:month/:day' do
  countdown_name
  haml :index
end
# date,name
get '/:year/:month/:day/:name' do
  countdown_name
  haml :index
end
# time
get '/:year/:month/:day/:hour::minute' do
  countdown_name
  haml :index
end
# time,name
get '/:year/:month/:day/:hour::minute/:name' do
  countdown_name
  haml :index
end

# special dates
get '/valentine' do
  uri = "2009/02/14/valentine's%20day"
  redirect(uri)
end
get '/timeforlost' do
  uri = "2009/1/21/21:00/time%20for%20lost"
  redirect(uri)
end

# stylesheets
get '/main.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :main
end

# === templates ===

use_in_file_templates!

__END__

@@ layout
!!! XML
!!! Strict
%html{ :xmlns => "http://www.w3.org/1999/xhtml", :lang => "en", 'xml:lang' => "en" }
  %head
    %title= "is it #{@name} yet?"
    %meta{'http-equiv'=>"content-type", :content=>"text/html; charset=UTF-8"}/
    %link{:href=>"/main.css", :media=>"all", :rel=>"stylesheet", :type=>"text/css"}/
        
  %body
    .container
      #content
        = yield
      #footer 
        %p
          %span.copyright
            something nifty from <a href="http://www.seaofclouds.com">seaofclouds</a>&trade; | 
            %a{:href=>"http://github.com/seaofclouds/is-it-blank-yet"} contribute
            
@@ index
%h2#status.content-header thinking
.content-body
  - if params[:name]
    %h3#notifier
  %h4#countdown
  %script{:type=>"text/javascript"}
    :plain
      var countdown_d = new Date();
      var countdown_timenow = countdown_d.getTime();
      var countdown_targetdate = Date.parse("#{params[:year]}/#{params[:month]}/#{params[:day]} #{params[:hour]}:#{params[:minute]}")
      var countdown_timeleft = Math.floor((countdown_targetdate-countdown_timenow)/1000);
      function countdown(remain,messages) {
        var
          status = document.getElementById("status"),
          notifier = document.getElementById("notifier"),
          countdown = document.getElementById("countdown"),
          timer = setInterval( function () {
            var day = (Math.floor(remain/86400))%86400;
            var hour = (Math.floor(remain/3600))%24;
            var minute = (Math.floor(remain/60))%60;
            var second = (Math.floor(remain/1))%60;
            countdown.innerHTML = (day > 0 ? day +" days " : "") + (hour > 0 ? hour +" hours " : "") + (minute > 0 ? minute +" minutes " : "") + (second > 0 ? second +" seconds " : "")
            if (--remain < 0 ) { 
              clearInterval(timer); 
              document.body.id = "yes"; 
              status.innerHTML = "yes"; 
              notifier.innerHTML = "it is #{@name}"
            } else {
              document.body.id = "no"; 
              status.innerHTML = "no"; 
              notifier.innerHTML = "it is not #{@name}"
            }
          },1000);          
      }
      countdown(countdown_timeleft,
        { 
          86400: "it will be #{@name} tomorrow.",
          10: "it will be #{@name} in ten seconds",
          0: "it is #{@name}"
        }
      );
      
@@ main
!green = #2E7F3A
!red = #7f0100
*
  :margin 0
  :padding 0
body
  :background-color #555
  :text-align center
  :color #fff
  :font-size 80%
  :font-family helvetica, arial, sans-serif
  a
    :color #fff
.container
  #content
    :padding-top 4em
    :padding-bottom 2em
    h2
      :font-weight normal
      :font-size 13em
      :font-family georgia, serif
    h3,h4
      :font-weight normal
      :font-size 1.5em
      :padding-top .5em
    h4
      :font-size 1.1em
      :margin-top 1em
    .content-body
      :padding-top 3em
      :padding-bottom 8em
      a
        :color #fff
#no
  :background-color = !red
  #footer
    :color = !red + #777
    a
      :color = !red + #777
#yes
  :background-color = !green
  #footer
    :color = !green + #777
    a
      :color = !green + #777
#footer
  :font-size .85em
  :padding-bottom 1em
  :font-family verdana, sans-serif