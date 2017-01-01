# Robotkit

## Installation

`gem install robotkit`

Or add this line `gem 'robotkit'` to your application's Gemfile and execute `bundle`

## Usage

`robotkit create :output_dir --package your.package.name`

Options
```
option :package, required: true
option :library_module, desc: "library module_name (default: library)"
option :sample_module, desc: "sample module_name (default: sample)"
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
