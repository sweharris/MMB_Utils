#!/usr/bin/perl -w
use strict;

# Beeb Utilities to manipulate MMB and SSD files
# Copyright (C) 2012 Stephen Harris
# 
# See file "COPYING" for GPLv2 licensing

use FindBin;
use lib "$FindBin::Bin";
use BeebUtils;

@ARGV=BeebUtils::init(@ARGV);

my $dest=$BeebUtils::BBC_FILE || 'BEEB.MMB';

die "$dest does not exists\n" unless -e $dest;
 
my $fh=new FileHandle "< $dest";
die "Can not open $dest for reading\n" unless $fh;

binmode($fh);

my $size=-s $dest;
my $ext=int($size/$BeebUtils::MMBSize);

printf("MMB Size is %d (0x%x) bytes\n",$size,$size);
printf("This is equivalent to %d extents\n",$ext);

if ($ext*$BeebUtils::MMBSize != $size)
{
  printf("WARNING: FILE is not correct size.\n  Should be: %d\n     Is: %d\n",$ext*$BeebUtils::MMBSize, $size);
}

foreach my $extent (0..$ext-1)
{
  print "\n";
  my $offset=$extent*$BeebUtils::MMBSize;
  printf("*** Extent %d at offset 0x%X ***\n",$extent,$offset);

  # Read the 8K into memory
  sysseek($fh,$offset,0);
  my $data;
  sysread($fh,$data,8192);

  foreach (0..3)
  {
    my $disk1=ord(substr($data,$_,1));
    my $disk2=ord(substr($data,$_+4,1));
    printf("%08X: Bytes %02X and %02X (Onboot disk %d): %02X %02X == %d\n",$offset+$_, $_,$_+4,$_,$disk1,$disk2,$disk1+256*$disk2);
  }

  my $byte=substr($data,8,1); $byte=ord($byte);
  printf("%08X: Byte 08 (Additional Extent): %02X\n",8+$offset,$byte);

  $byte=substr($data,9,1); $byte=ord($byte);
  printf("%08X: Byte 09 (DBASE): %02X\n",9+$offset,$byte);

  foreach (10..15)
  {
    printf("%08X: Byte %02X (Unused): %02X\n", $_+$offset,$_,ord(substr($data,$_,1)));
  }

  foreach my $slot (1..511)
  {
    my $titlehex="";
    my $title="";
    foreach (0..15)
    {
      my $byte=substr($data,$slot*16+$_,1); $byte=ord($byte);
      $titlehex .= sprintf("%02X ",$byte);
      if ($byte < 32 || $byte > 126)
      {
         $title .= ".";
      }
      else
      {
         $title .= chr($byte);
      }
    }
    printf("%08X: %4d: %s%s\n", $slot*16+$offset,$slot-1+511*$extent,$titlehex,$title);
  }
  printf("%08X: image data starts\n",8192+$offset);
}
