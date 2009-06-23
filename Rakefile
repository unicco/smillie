# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

desc "Update pot/po files."
task :updatepo do
  require 'gettext/utils'
  GetText.update_pofiles("smillie", #テキストドメイン名(init_gettextで使用した名前) 
                         Dir.glob("{app,config,components,lib}/**/*.{rb,erb,rjs}"),  #ターゲットとなるファイル
                         "smillie 1.0.0"  #アプリケーションのバージョン
                         )
end

desc "Create mo-files"
task :makemo do
  require 'gettext/utils'
  GetText.create_mofiles(true, "po", "locale")
end
