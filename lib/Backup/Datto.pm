# Datto.pm
# Copyright (C) 2016 Matthew Topper topperm9@gmail.com
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

package Backup::Datto;

# Boilerplate
use warnings;
use strict;
our $VERSION = "0.1.1";

use warnings;
use strict;

use constant TRUE  => 1;
use constant FALSE => 0;

1;

__END__

=head1 NAME

Backup::Datto::Device - A class representing a physical Datto appliance.

=head1 VERSION

This document describes Datto version 0.1.1.  It is designed to be used by the
DattoCollection class, and as a result, most of its interface is not public.

Information about the private interface is commented inline, and minimally here.

Note that and function starting with _priv is not guaranteed to remain in future
releases.

=head1 SYNOPSIS

Note:  This is not useful without something setting the values below.
See Device.pm for more details

my $datto = new Backup::Datto::Device();

"Serial Number is " . $datto->get_serial_number(). "\n";
"Device hostname is " . $datto->get_hostname() . "\n";
"Device Model is " . $datto->get_model() . "\n";
"Free Space is " . $datto->get_free_space() . "\n";
"Used Space is " . $datto->get_used_space() . "\n";
"Device has been up for " . $datto->get_uptime() . " seconds\n";
"Internal IP is " . $datto->get_internal_ip() . "\n";
"Device last seen at " . $datto->get_last_seen() . "\n";
"Current transmit limit is " . $datto->get_tx_limit_kb() . "\n";



=head1 DESCRIPTION

This module is the base class containing definitions that
need to exist across all of the modules.  For example, T/F constants

=head1 AUTHOR

Matthew Topper, mtopper@cpan.org

=head1 LICENSE AND COPYRIGHT

Copyright (C), Matthew Topper.  All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

=cut