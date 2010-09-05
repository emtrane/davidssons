require 'net/ftp'

# http://www.tylerclemons.com/ftp-fun-with-ruby/
def send_it(local, remote)

  puts "sending " + local

  #open local and remote directories
  Dir.chdir(local)
  @ftp.chdir(remote)
  #make a local copy of file list to reduce network calls
  remote_list = @ftp.nlst()
  Dir.entries(".").each do |thefile|
    #be sure not to try and send the current and parent directory
    if thefile != "." and thefile != ".."
      filename = File.basename(thefile)
      #check if this is a file
      if not File.directory?(thefile)
        @ftp.putbinaryfile(thefile,thefile)
      else
        if not remote_list.index(filename)
          @ftp.mkdir(filename)
        end
        #make recursive call
        send_it(filename,filename)
        #move back up to parent directory after sending directory
        @ftp.chdir("..")
        Dir.chdir("..")
      end
    end
  end
end

username = ARGV[0]
password = ARGV[1]

local = "."
remote = "/public_html/"

@ftp = Net::FTP.new('ftp.davidssons.com')
@ftp.login(username, password)
#files = ftp.chdir('pub/lang/ruby/contrib')
#files = ftp.list('n*')
#ftp.getbinaryfile('nif.rb-0.91.gz', 'nif.gz', 1024)

send_it(local, remote)

@ftp.close
