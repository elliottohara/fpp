#!/bin/sh
#
# asplashscreen install/upgrade script
#
# Update /etc/init.d/asplashscreen
#

cat <<-EOF > /etc/init.d/asplashscreen
#!/usr/bin/perl
### BEGIN INIT INFO
# Provides:          asplashscreen
# Required-Start:
# Required-Stop:
# Should-Start:
# Default-Start:     S
# Default-Stop:
# Short-Description: Show custom splashscreen
# Description:       Show custom splashscreen
### END INIT INFO

#########################################################################
# Some hard-coded or default values
# Turn on debugging printf's (set to 0 to turn off)
$debug       = 0;
#
# Video Filename
$videoFile   = "/etc/splash.mp4";
#
# Percentage of Screen vertically that we want to fill with the video
$percentFill = 60;
#
# HardCode the video dimensions so we don't have to call omxplayer to get this
$videoWidth  = 800;
$videoHeight = 450;
#
#########################################################################
# Some Variables
# Storage for the 4 values we pass to omxplayer --win
$x1 = 0;
$y1 = 0;
$x2 = $videoWidth;
$y2 = $videoHeight;
#
$videoAspect = 1.0 * $videoWidth / $videoHeight;
$screenSize = `fbset | grep "^mode" | cut -f2 -d\\"`;
chomp($screenSize);

$screenWidth = $screenSize;
$screenWidth =~ s/x.*//;

$screenHeight = $screenSize;
$screenHeight =~ s/.*x//;

$screenAspect = 1.0 * $screenWidth / $screenHeight;

$desiredHeight = $screenHeight * $percentFill * 0.01;
$desiredWidth  = $desiredHeight * $videoAspect;

if ($desiredWidth >= $screenWidth)
{
	$desiredWidth = $screenWidth;
	$desiredHeight = $desiredWidth / $videoAspect;

	$x2 = $desiredWidth;
	$y2 = $desiredHeight;
}
else
{
	$x1 = int(($screenWidth - $desiredWidth) / 2);
	$y1 = 0;
	$x2 = $x1 + $desiredWidth;
	$y2 = $desiredHeight;
}


#########################################################################
# Print out some vars for debugging (change to 0 to disable debug printfs)
if ($debug)
{
	printf( "Video Width    : %d\n", $videoWidth);
	printf( "Video Height   : %d\n", $videoHeight);
	printf( "Video Aspect   : %.5f\n", $videoAspect);
	printf( "Screen Size    : %s\n", $screenSize);
	printf( "Screen Width   : %d\n", $screenWidth);
	printf( "Screen Height  : %d\n", $screenHeight);
	printf( "Screen Aspect  : %.5f\n", $screenAspect);
	printf( "Percent Fill   : %d%%\n", $percentFill);
	printf( "Desired Height : %d\n", $desiredHeight);
	printf( "Desired Width  : %d\n", $desiredWidth);
	printf( "X1             : %d\n", $x1);
	printf( "Y1             : %d\n", $y1);
	printf( "X2             : %d\n", $x2);
	printf( "Y2             : %d\n", $y2);
}
#########################################################################
# Now run the video
$cmd = sprintf( "omxplayer --win \"%d %d %d %d\" %s > /dev/null &", $x1, $y1, $x2, $y2, $videoFile);
if ($debug)
{
	printf( "CMD: %s\n", $cmd);
}
system($cmd);
EOF

insserv /etc/init.d/asplashscreen