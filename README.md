# Mitty
[![Build Status](https://travis-ci.org/tcdowney/mitty.svg)](https://travis-ci.org/tcdowney/mitty)

> Number 25 is my best ever, the quintessence of life, I think. I trust you'll get it where it needs to go, you always do. 

-- Sean O'Connell, [The Secret Life of Walter Mitty](http://www.imdb.com/title/tt0359950/)

Mitty is a command line tool for managing your digital photographic assets.  It will currently resize your jpeg images, generate thumbnails, generate lower quality versions of your images, and upload them all to an Amazon Web Services S3 bucket!

Like Walter Mitty, the `mitty` gem will help you get your images where they need to go.  In my case, that means it makes getting images on to my [static photo blog](http://photo.downey.io/) less painful.

__CAUTION:__
While functional, `mitty` is still pre-release software and definitely not stable.  I plan on iterating on it and will be making non-passive changes until I'm satisfied with it.  Use at your own risk. 

:scream::scream::fearful::wink:

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mitty'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mitty

## Configuration
The `mitty` gem can currently be configured with a `.mitty` file in your home directory, or a `.mitty` file in the directory in which you are executing the gem.  A configuration file can also be passed in to the CLI commands directly by providing the `-c` argument.

Additionally, sensitive configuration can be configured using the following environment variables.
* `AWS_ACCESS_KEY_ID` - your AWS access key ID
* `AWS_SECRET_ACCESS_KEY` - your AWS secret access key

These are the same environment variables that the `aws-sdk` gem is aware of, so chances are you may have them already configured.

### Example Configuration File
```yaml
## Amazon Web Services Config
# Your AWS access key ID (note: can be supplied via environment variable)
aws_access_key_id: 'SOME AWS ACCESS KEY ID'

# Your AWS secret access key (note: can be supplied via environment variable)
aws_secret_access_key: 'SOME AWS SECRET ACCESS KEY'

# The name of the AWS S3 bucket you want to upload to
aws_s3_bucket: 'example.s3.bucket'

# The AWS region your bucket resides in
aws_region: 'us-east-1'

# The default acl value used when uploading to S3
aws_default_acl: 'private'

# The value used when uploading original copies of images to S3
aws_original_copy_acl: 'private'

# Valid ACL values: 
# 'private', 'public-read', 'public-read-write', 
# 'authenticated-read', 'bucket-owner-read', 'bucket-owner-full-control'

## Image Maniupulation Config

# These values denote the width of each size in pixels
thumbnail_image_size: 125
small_image_size: 250
medium_image_size: 500
large_image_size: 1000

# This value sets the quality level for normal resized versions of images
normal_quality_value: 95

# This value sets the quality level for low quality versions of images
low_quality_value: 25

## Miscellaneous Config

# Controls whether or not low quality duplicates of images will be generated
# Useful for loading lower quality images first and replacing with their higher
# quality counterparts after the page has loaded
generate_low_quality: true

# Controls whether or not image color profiles and comments should be removed
# Stripping out this metadata will result in lower filesizes
strip_color_profiles: true
```

## Usage
__CAUTION:__ As noted earlier, this is a pre-release version of the gem (:scream:).  With that in mind, the following commands are hardly set in stone and are liable to change.

Installing `mitty` will install an executable `mitty` command.  Currently, the `mitty` command has three operations available:

* `mitty resize FILE_PATH`
* `mitty upload FILE_PATH`
* `mitty manage FILE_PATH`

For a detailed description of each command, run `mitty help COMMAND_NAME`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tcdowney/mitty.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
