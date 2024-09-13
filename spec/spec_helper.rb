require 'chefspec'
require 'chefspec/berkshelf'

ALMA_8 = {
  platform: 'almalinux',
  version: '8',
}.freeze

ALL_PLATFORMS = [
  ALMA_8,
].freeze

RSpec.configure do |config|
  config.file_cache_path = '/var/chef/cache'
end
