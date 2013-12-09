root = File.absolute_path(File.dirname(__FILE__))

Dir.glob(File.expand_path('../site-cookbooks/*', __FILE__)).each do |path|
    metadata :path => path
end

file_cache_path root
cookbook_path root + '/cookbooks

