---
title:      Ruby be nimble, Ruby be SWF...
created_at: 2008-09-04 12:00:00 +00:00
layout:     default
tags:       ruby
---

This is a quick post with notes on the [SWF format](http://www.adobe.com/devnet/swf/pdf/swf_file_format_spec_v9.pdf). Well so far it's only one really, and it is in reference to compression.

From page 13, 3rd paragraph in the documentation;

"The FileLength field is the total length of the SWF file, including the header. If this is an
uncompressed SWF file (FWS signature), the FileLength field should exactly match the file
size. If this is a compressed SWF file (CWS signature), the FileLength field indicates the total
length of the file after decompression, and thus generally does not match the file size. Having
the uncompressed size available can make the decompression process more efficient."

Seems pretty clear and straight forward, but it doesn't really reference where the compression starts. I initially assumed, that it starts at the end of the SWF header. The end of the header seemed like a logical boundary to me. What I quickly found with [0xED](http://www.suavetech.com/0xed/0xed.html) is that compression starts immediately after the 32-bit FileLength. Okay so now we know, and knowing is half the battle! What next?

### Toes to the edge, and wait for the gun.

Okay so we know that the compression starts **after** the length. How do we decompress it? Enter the standard Zlib library built-in to Ruby. It starts with a simple;

`require 'zlib'`

And requires the compressed contents in a string buffer like so;

    def read_remaining_bytes
      pos = @file.tell
      @file.seek( 0, IO::SEEK_END )
      end_pos = @file.tell
      @file.pos = pos
      @file.read( end_pos - pos )
    end

Note: @file is a file handle using File.new( filename, 'r' ), it is assumed the position in the file is the first byte immediately after the SWF length attribute. See SwfReader in [Ruby-Swfer](http://junctionbox.ca/projects/ruby-swfer/) for further details.

### Inflate those water wings and kick!

Okay we have our compressed content now lets inflate it!

    def decompress( compressed_contents )
      zstream = Zlib::Inflate.new
      decompressed_contents = zstream.inflate( compressed_contents )
      zstream.finish
      zstream.close
      decompressed_contents
    end

And voila, you should have all your bytes in a nice little (big) string. All you have left is to run through each byte and decode to your hearts content.
