# frozen_string_literal: false

# # load all ruby files in the directory "lib" and its subdirectories
require "require_all"

require_all "."
require_all "../lib"

class FS_DCAT_Proxy < Sinatra::Base

  set_routes()

end
