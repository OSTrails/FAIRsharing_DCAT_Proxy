# frozen_string_literal: true

require_relative "fs_dcat_proxy/version"
require "sinatra"
require "json"
require "erb"
require 'uri'
require 'require_all'
require_relative  "cache"
require_relative  "metadata_functions"
require_relative  "queries"

require "json"
require "linkeddata"
require "rest-client"
require "require_all"
require "rdf/vocab"

require_all "."

module FS_DCAT_Proxy
  class Error < StandardError
    

  end
  # Your code goes here...
end
