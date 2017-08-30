require 'chefspec'
require 'chefspec/berkshelf'

ChefSpec::Coverage.start! { add_filter 'osl-ceph' }

CENTOS_7 = {
  platform: 'centos',
  version: '7.2.1511'
}.freeze

ALL_PLATFORMS = [
  CENTOS_7
].freeze

RSpec.configure do |config|
  config.log_level = :fatal
end
