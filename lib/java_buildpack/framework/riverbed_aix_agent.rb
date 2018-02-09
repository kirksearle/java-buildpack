# frozen_string_literal: true

# Cloud Foundry Java Buildpack
# Copyright 2013-2018 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'fileutils'
require 'java_buildpack/component/versioned_dependency_component'
require 'java_buildpack/framework'
module JavaBuildPack
  module Framework
    class RiverbedAixAgent < JavaBuildpack::Component::VersionedDependencyComponent
      #jbp constants
      FILTER = /(?i)riverbed[-_]aix[-_]agent/

      #credentials key
      DSA_PORT = 'dsa_port'
      AGENTRT_PORT = 'agentrt_port' #TODO: change "AGENTRT" once we have a name

      #javaagent args
      INSTANCE_NAME = 'instance_name'

      #env
      AIX_INSTRUMENT_ALL = 'AIX_INSTRUMENT_ALL'
      RVBD_AGENT_FILES = 'RVBD_AGENT_FILES'
      RVBD_DSA_HOST = 'RVBD_DSAHOST'

      #constants
      DSA_PORT_DEFAULT = 2111
      AGENTRT_PORT_DEFAULT = 7073


      private_constant :FILTER, :AGENTRT_PORT,
                       :DSA_PORT,
                       :INSTANCE_NAME,
                       :AIX_INSTRUMENT_ALL,
                       :RVBD_AGENT_FILES,
                       :RVBD_DSA_HOST,
                       :DSA_PORT_DEFAULT,
                       :AGENTRT_PORT_DEFAULT

      def initialize(context)
        super(context)
        @logger = JavaBuildpack::Logging::LoggerFactory.instance.get_logger RiverbedAixAgent
        @logger.warn("***fan*** in function initialize(context), logger just initialized!")
      end

      def compile
        @logger.warn("***fan*** test, in compile!!! droplet = #{@droplet.sandbox}, java_home=#{@droplet.java_home}, version=#{@version}, application=#{@application},\
        uri=#{@uri}, component_name=#{@component_name}")
        download_zip(false, @droplet.sandbox, @component_name)
        # TODO: check for CF guys' response about the usage of this utility...
        # TODO: why can't i just zip resources altogether with other binaries?
        # TODO: is this the place for a config file??
        @droplet.copy_resources

      end

      def release
        @logger.warn("***fan*** test, in release!!!")
        credentials = @application.services.find_service(FILTER)['credentials']
        setup_env credentials
        setup_javaopts credentials
      end

      def supports?
        @application.services.one_service?(FILTER) && os.casecmp('Linux') == 0
      end

      def setup_javaopts(credentials)
        @droplet.java_opts.add_agentpath(agent_path)
        instance_name = credentials[INSTANCE_NAME]
        #TODO: remove this if not working, and use instance.name for agentpath arg instead
        @droplet.java_opts.add_system_property('riverbed.moniker',instance_name) unless instance_name.nil?
      end

      def setup_env (credentials)
        set_env_var(DSA_PORT.upcase,credentials[DSA_PORT] || DSA_PORT_DEFAULT)
        set_env_var(AGENTRT_PORT.upcase,credentials[AGENTRT_PORT] || AGENTRT_PORT_DEFAULT)
        set_env_var(AIX_INSTRUMENT_ALL,1)
        set_env_var(RVBD_AGENT_FILES,1)
        set_env_var(RVBD_DSA_HOST, @application.environment['CF_INSTANCE_IP'])
      end

      def set_env_var(key, val)
        @droplet.environment_variables.add_environment_variable(key,val) unless val.nil?
      end

      def architecture
        `uname -m`.strip
      end

      def os
        `uname`.strip
      end

      def agent_path
        lib_dir + lib_ripl_name
      end

      def agent_dir
        @droplet.sandbox + 'agent'
      end

      def lib_dir
        agent_dir + 'lib'
      end

      def classes_dir
        agent_dir + 'classes'
      end

      def lib_ripl_name
        architecture == 'x86_64' || architecture == 'i686' ? 'librpilj64.so' : 'librpilj.so'
      end

    end
  end
end
