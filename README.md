pdf-split-convert
=================

## Queuing in Ruby

```
require "iron_worker_ng"

client = IronWorkerNG::Client.new

input = {
  :url_in => 'https://s3.amazonaws.com/marketplace-test/testpage_single.pdf',
  :master => true,

  :aws => {
    :access => 'AWS_ACCESS',
    :secret => 'AWS_SECRET',
    :bucket => 'AWS_BUCKET'
  },

  :iron => {
    :project_id => 'IRON_PROJECT_ID',
    :token => 'IRON_TOKEN'
  }
}

client.tasks.create("pdf-split-convert", input)
```