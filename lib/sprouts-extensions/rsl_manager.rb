require 'fileutils'

class RSLManager
  include Singleton

  attr_reader :source_dir, :output_dir

  def load_params(params)
    @source_dir, @output_dir = params.values_at(:source_dir, :output_dir)
    @rsls, @trust_file_name = params.values_at(:rsls, :trust_file_name)
  end

  def copy_files
    FileUtils.mkdir_p output_dir
    @rsls.each do |rsl|
      FileUtils.cp File.join(source_dir, 'frameworks/rsls', rsl), output_dir
    end
  end

  def add_output_to_trust_dirs
    File.open(File.join(trust_dir, @trust_file_name), 'w') do |file|
      file.puts(File.expand_path(output_dir))
    end
  end

  private
  # based on http://www.adobe.com/devnet/flashplayer/articles/flash_player_admin_guide/flash_player_admin_guide.pdf
  # around page 83
  def trust_dir
    if PLATFORM =~ /(mswin)|(mingw)/
      # vista
      # "C:\Users\username\AppData\Roaming\Macromedia\Flash Player\#Security\FlashPlayerTrust"

      # windows 2000 & XP
      File.join(ENV['HOME'], 'Application Data\Macromedia\Flash Player\#Security\FlashPlayerTrust')
    elsif PLATFORM =~ /darwin/  
      File.join(ENV['HOME'], 'Library/Preferences/Macromedia/Flash Player/#Security/FlashPlayerTrust')
    elsif PLATFORM =~ /linux/
        File.join(ENV['HOME'], '.macromedia/#Security/FlashPlayerTrust')
    else
      raise "Unsupported platform #{PLATFORM}"
    end
  end
end