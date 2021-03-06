#
# Cookbook Name:: osops-utils
# Library:: Chef::Recipe::Patch
#
# Copyright 2009, Rackspace US, Inc.
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

class Chef::Recipe::Patch
  def self.check_package_version(package,version,nodeish = nil)
    nodeish = node unless nodeish
    # TODO(breu): remove nova-apply_patches sometime in the future
    if not (nodeish["osops"]["apply_patches"] or nodeish["nova"]["apply_patches"])
      Chef::Log.info("osops-utils/patch: package #{package} skipping hotfix for #{version} due to node settings")
      return false
    end
    case nodeish["platform"]
    when "ubuntu", "debian"
      Mixlib::ShellOut.new("apt-cache policy #{package}").run_command.stdout.each_line do |line|
        case line
        when /^\s{2}Installed: (.+)$/
          if $1 == version
              Chef::Log.info("osops-utils/patch: package #{package} requires a hotfix for version #{version}")
              return $1 == version
          end
        end
      end
    when "fedora", "centos", "redhat", "scientific", "amazon"
      #TODO(breu): need to test this for fedora
      Mixlib::ShellOut.new("rpm -q --queryformat '%{VERSION}-%{RELEASE}\n' #{package}").run_command.stdout.each_line do |line|
        case line
        when /^([\w\d_.-]+)$/
          if $1 == version
              Chef::Log.info("osops-utils/patch: package #{package} requires a hotfix for version #{version}")
              return $1 == version
          end
        end
      end
    end
    return false
  end
end
