Gem::Specification.new do |s|
  s.name = %q{lcdproc-ruby}
  s.version = "0.1.1"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["topherfangio"]
  s.date = %q{2009-06-19}
  s.email = %q{fangiotophia@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "TODO",
     "VERSION",
     "devices/crystalfontz/packet.rb",
     "devices/devices.rb",
     "examples/basic.rb",
     "examples/clock.rb",
     "examples/lights.rb",
     "lcdproc.rb",
     "lib/console.rb",
     "lib/core_extensions/array.rb",
     "lib/core_extensions/string.rb",
     "lib/includes/lcdproc.rb",
     "lib/lcdproc-ruby.rb",
     "lib/lcdproc/client.rb",
     "lib/lcdproc/command.rb",
     "lib/lcdproc/errors.rb",
     "lib/lcdproc/key_event.rb",
     "lib/lcdproc/menu.rb",
     "lib/lcdproc/menu_event.rb",
     "lib/lcdproc/menu_item.rb",
     "lib/lcdproc/menu_items/action.rb",
     "lib/lcdproc/menu_items/alpha.rb",
     "lib/lcdproc/menu_items/checkbox.rb",
     "lib/lcdproc/menu_items/ip.rb",
     "lib/lcdproc/menu_items/numeric.rb",
     "lib/lcdproc/menu_items/ring.rb",
     "lib/lcdproc/menu_items/slider.rb",
     "lib/lcdproc/menu_items/submenu.rb",
     "lib/lcdproc/response.rb",
     "lib/lcdproc/screen.rb",
     "lib/lcdproc/widget.rb",
     "lib/lcdproc/widgets/graph.rb",
     "lib/lcdproc/widgets/hbar.rb",
     "lib/lcdproc/widgets/icon.rb",
     "lib/lcdproc/widgets/num.rb",
     "lib/lcdproc/widgets/scroller.rb",
     "lib/lcdproc/widgets/string.rb",
     "lib/lcdproc/widgets/title.rb",
     "lib/lcdproc/widgets/vbar.rb",
     "script/console.rb",
     "script/telnet.rb",
     "tasks/test/basic.rake",
     "tasks/test/keys.rake",
     "tasks/test/menus.rake"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/topherfangio/lcdproc-ruby}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.0.1}
  s.summary = %q{A Ruby library to interface with LCDProc.}
  s.test_files = [
    "examples/basic.rb",
     "examples/clock.rb",
     "examples/lights.rb"
  ]
end
