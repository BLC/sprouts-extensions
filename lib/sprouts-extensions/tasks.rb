require 'sprouts-extensions/rsl_manager'

namespace :rsl do
  desc "Copies the specified framework rsls into the output directory"
  task :copy do
    RSLManager.instance.copy_files
  end

  desc "Sets up the output directory of the rsls to be a trusted dir for running in the flash stand-alone"
  task :configure_trust do
    RSLManager.instance.add_output_to_trust_dirs
  end

  desc "Sets up the rsls"
  task :setup => ['copy', 'configure_trust']
end