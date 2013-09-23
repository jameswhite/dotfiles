#!/usr/bin/env ruby

git_bundles = [ 
  "https://github.com/airblade/vim-gitgutter.git",
  "https://github.com/arafatm/todohabit.vim.git",
  "https://github.com/mattn/gist-vim.git",
  "https://github.com/msanders/snipmate.vim.git",
  "https://github.com/scottmcginness/vim-jquery.git",
  "https://github.com/thinca/vim-ft-markdown_fold.git",
  "https://github.com/tpope/vim-fugitive.git",
  "https://github.com/tpope/vim-rails.git",
  "https://github.com/tpope/vim-bundler.git",
  "https://github.com/vim-ruby/vim-ruby.git",
	"https://github.com/vim-scripts/JavaScript-Indent.git",
  "https://github.com/vim-scripts/Markdown.git",
  "https://github.com/rodjek/vim-puppet.git"
]

vim_org_scripts = [
#  ["gist",          "15897",  "plugin"],
#  ["jquery",        "12107",  "syntax"]
]

require 'fileutils'
require 'open-uri'

bundles_dir = File.join(File.dirname(__FILE__), "bundle")

FileUtils.cd(bundles_dir)

puts "Trashing everything (lookout!)"
Dir["*"].each {|d| FileUtils.rm_rf d }

git_bundles.each do |url|
  dir = url.split('/').last.sub(/\.git$/, '')
  puts "  Unpacking #{url} into #{dir}"
  `git clone #{url} #{dir}`
  FileUtils.rm_rf(File.join(dir, ".git"))
end

vim_org_scripts.each do |name, script_id, script_type|
  puts "  Downloading #{name}"
  local_file = File.join(name, script_type, "#{name}.vim")
  FileUtils.mkdir_p(File.dirname(local_file))
  File.open(local_file, "w") do |file|
    file << open("http://www.vim.org/scripts/download_script.php?src_id=#{script_id}").read
  end
end

system("ln -s ../repo/* .")
