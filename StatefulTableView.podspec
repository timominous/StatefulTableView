Pod::Spec.new do |s|
	s.name = 'StatefulTableView'
	s.version = '0.1.2'
	s.license = {
		:type => 'MIT',
		:file => 'LICENSE'
	}
	s.homepage = 'http://github.com/timominous/StatefulTableView'
	s.description = 'Custom UITableView container class that supports pull-to-refresh, load-more, initial load, and empty states. Swift port of SKStatefulTableViewController'
	s.summary = 'Custom UITableView container class that supports pull-to-refresh, load-more, initial load, and empty states.'
	s.author = {
		'timominous' => 'timominous@gmail.com'
	}
	s.source = {
		:git => 'https://github.com/timominous/StatefulTableView.git',
		:tag => s.version.to_s
	}
	s.ios.deployment_target = "8.0"
	s.source_files = 'Sources/*.swift'
	s.requires_arc = true
	s.swift_versions = ['5.0']
end
