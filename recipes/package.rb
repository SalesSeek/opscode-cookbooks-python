#
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: python
# Recipe:: package
#
# Copyright 2011, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

node.set['python']['major_version'], \
node.set['python']['minor_version'], \
node.set['python']['micro_version'] = 
  node['python']['version'].split('.').map {|v| v.to_i}

if node['python']['major_version'] > 2 and platform_family?('debian')
  python_version_suffix = node['python']['major_version'].to_s
  if node['python']['minor_version']
    python_version_suffix += ".#{node['python']['minor_version']}"
  end
else
  python_version_suffix = ''
end
node.set['python']['version_suffix'] = python_version_suffix

major_version = node['platform_version'].split('.').first.to_i

# COOK-1016 Handle RHEL/CentOS namings of python packages, by installing EPEL
# repo & package
if platform_family?('rhel') && major_version < 6
  include_recipe 'yum::epel'
  python_pkgs = ["python26", "python26-devel"]
  node.set['python']['binary'] = "/usr/bin/python26"
else
  pv = node['python']['version_suffix']
  python_pkgs = value_for_platform_family(
                  "debian" => ["python#{pv}","python#{pv}-dev"],
                  "rhel" => ["python","python-devel"],
                  "freebsd" => ["python"],
                  "smartos" => ["python27"],
                  "default" => ["python","python-dev"]
                )
  node.set['python']['binary'] = \
    node['python']['binary'] + node['python']['version_suffix']
end

python_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end
