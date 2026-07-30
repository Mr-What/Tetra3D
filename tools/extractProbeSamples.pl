#!/usr/bin/perl -W
# extract data from individual probes, NOT the result.
# This is to check for repeatability, not for final probe estimate
while(<STDIN>)
{
    if(m/probe:.*bed will contact at/)
    {
	s/probe: at\s+//;
	s/ bed will contact at z=/,/;
	print $_;
    }
}
