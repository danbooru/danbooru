namespace :jrails do

	namespace :js do
		desc "deprecated. Please use ./script/generator jrails"
		task :install do
			#puts "Copying files..."
			#project_dir = RAILS_ROOT + '/public/javascripts/'
			#scripts = Dir[File.join(File.dirname(__FILE__), '..', '/javascripts/', '*.js')]
			#FileUtils.cp(scripts, project_dir)
			puts "please use ./script/generator jrails"
		end

    desc 'Remove the prototype / script.aculo.us javascript files'
    task :scrub do
      puts "Removing files..."
      files = %W[controls.js dragdrop.js effects.js prototype.js]
      project_dir = File.join(Rails.root, 'public', 'javascripts')
      files.each do |fname|
        FileUtils.rm(File.join(project_dir, fname)) if File.exists?(File.join(project_dir, fname))
      end
      puts "files removed successfully."
    end
  end
  
end
