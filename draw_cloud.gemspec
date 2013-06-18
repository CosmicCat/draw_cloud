# -*- mode: ruby -*-
# -*- encoding: utf-8 -*-
#
# Copyright 2013 SweetSpot Diabetes Care, Inc.
#  
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this work except in compliance with the License. You may
# obtain a copy of the License in the LICENSE file, or at:
#  
# http://www.apache.org/licenses/LICENSE-2.0
#  
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied. See the License for the specific language governing
# permissions and limitations under the License.
$:.unshift File.expand_path('../lib', __FILE__)
require 'draw_cloud/version'

Gem::Specification.new do |gem|
  gem.name        = 'draw_cloud'
  gem.version     = DrawCloud::VERSION
  gem.platform    = Gem::Platform::RUBY
  gem.summary     = 'Create AWS CloudFormation configurations using a Ruby DSL'
  gem.description = File.read("README.md")
  gem.licenses    = ['APL 2.0']

  gem.authors     = ['SweetSpot Diabetes']
  gem.email       = ['support@sweetspotdiabetes.com']
  gem.homepage    = 'https://github.com/sweetspot/draw_cloud'

  gem.required_ruby_version     = '>= 1.9.2'
  gem.required_rubygems_version = '>= 1.3.6'

  gem.files        = Dir['README.md']
  gem.files       += Dir['lib/**/*']

  gem.require_path = "lib"

  gem.add_runtime_dependency "deep_merge"
  gem.add_runtime_dependency "activesupport"
  
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
end
