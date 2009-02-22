# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{acts_as_secure}
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Revolution on Rails", "Joe Scharf"]
  s.date = %q{2009-02-10}
  s.description = %q{Acts as secure adds automatic encryption and decryption to an ActiveRecord model}
  s.email = %q{joe@obility.net}
  s.files = ["CHANGELOG", "init.rb", "lib", "lib/acts_as_secure.rb", "MIT-LICENSE", "Rakefile", "README" ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/jscharf/acts_as_secure}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{acts_as_secure}
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{Acts as secure adds automatic encryption and decryption to an ActiveRecord model}

end
