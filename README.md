# Utilities

## Split Convert
  * Dependency - requires sqlines on PATH -> [sqlines](http://sqlines.com)
  * Create split & conv dir
  * Split input file by linecount specified
  * Convert splits using sqlines
  * Output converted sql to conv dir


## Format - Byte Sector & Progress
  * Dependency - requires sg3_utils
  * Defaults to /dev/sdb until /dev/sdy and 512 byte sector

## Format - GPT label, create ext4 partition
  * Dependency - requires fdsik
  * Defaults to GPT label and ext4
