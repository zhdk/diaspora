#once, run jdconfig.rb
#worker cleanup
#Resque.workers.each {|w| w.unregister_worker}

#how I deploy jd.com to heroku
git pull
git checkout joindiapsora
git rebase TAGNUMBER


heroku maintenance:on -a diaspora-production
ruby jdconfig.rb
git push heroku joindiaspora:master
heroku run 'rails runner "AssetSync.sync"'

heroku maintenance:off -a diaspora-production
