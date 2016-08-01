# Device.pm
# Copyright (C) 2014 Matthew Topper topperm9@gmail.com
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

package Backup::Datto::Device;

# Boilerplate
use warnings;
use strict;
our $VERSION = "0.1.1";

use warnings;
use strict;

# These values are used to keep the class internally consistent
my $STRING_SERIAL          = 'SerialNumber';
my $STRING_HOSTNAME        = 'Hostname';
my $STRING_UPTIME          = 'Uptime';
my $STRING_MODEL           = 'Model';
my $STRING_FREESPACE       = 'FreeSpace';
my $STRING_USEDSPACE       = 'UsedSpace';
my $STRING_INTERNALIP      = 'InternalIP';
my $STRING_TXLIMIT         = 'TxSpeedLimit';
my $STRING_LAST_SEEN       = 'Lastseen';
my $STRING_AGENTS          = 'DattoAgents';
my $STRING_SERVICE_EXPIRE  = 'ServiceExpire';
my $STRING_WARRANTY_EXPIRE = 'WarrantyExpire';
my $STRING_HIDDEN          = 'IsHidden';
my $STRING_LOAD_AVERAGE    = 'FiveMinLoadAvg';
my $STRING_ZFS_VERSION     = 'ZFSVersion';
my $STRING_KERNEL_VERSION  = 'KernelVersion';
my $STRING_BIOS_VERSION    = 'BIOSVersion';
my $STRING_VBOX_VERSION    = 'VBoxVersion';

# Explicitly define true/false rather than 0 or not 0
my $TRUE  = 1;
my $FALSE = 0;

sub
new
{
    my $class = shift;
    
    my $self  = {
        $STRING_SERIAL          => undef,
        $STRING_HOSTNAME        => undef,
        $STRING_MODEL           => undef,
        $STRING_FREESPACE       => undef,
        $STRING_USEDSPACE       => undef,
		$STRING_UPTIME          => undef,
        $STRING_INTERNALIP      => undef,
        $STRING_LAST_SEEN       => undef,
        $STRING_TXLIMIT         => undef,
        $STRING_AGENTS          => undef,
        $STRING_SERVICE_EXPIRE  => undef,
        $STRING_WARRANTY_EXPIRE => undef,
        $STRING_HIDDEN          => undef,
        $STRING_LOAD_AVERAGE    => undef,
        $STRING_ZFS_VERSION     => undef,
        $STRING_VBOX_VERSION    => undef,
        $STRING_KERNEL_VERSION  => undef,
        $STRING_BIOS_VERSION    => undef
    };
	
	bless( $self, $class );
	
	return $self;
}

##
## Public methods
## These methods are guaranteed to exist in future versions
## of this module and to be called externally
##

# Accessor method for the device's serial number
sub
get_serial_number
{
    my $self = shift;
    
    return $self->{ $STRING_SERIAL };
}

# Accessor method for the device's hostname
sub
get_hostname
{
	my $self = shift;
	
	return $self->{ $STRING_HOSTNAME };

}

# Accessor method for the device's model number
sub
get_model
{
    my $self = shift;
    
    return $self->{ $STRING_MODEL };
}

# Accessor method for the amount of free space on the device, in KB.
sub
get_free_space
{
    my $self = shift;
    
    return $self->{ $STRING_FREESPACE };
}

# Accessor method for the amount of used space on the device, in KB.
sub
get_used_space
{
    my $self = shift;
    
    return $self->{ $STRING_USEDSPACE };
}

# Access method for the device's uptime, in seconds
sub
get_uptime
{
    my $self = shift;
    
    return $self->{ $STRING_UPTIME };
}

# Accessor method for the device's internal IP, as a stirng
sub
get_internal_ip
{
    my $self = shift;
    
    return $self->{ $STRING_INTERNALIP };
}

# Accessor method for the device's last checkin time, as a string
sub
get_last_seen
{
    my $self = shift;
    
    return $self->{ $STRING_LAST_SEEN };
}

# Accessor method for the device's current upload speed limit
sub
get_tx_limit_kb
{
    my $self = shift;
    
    return $self->{ $STRING_TXLIMIT };
}

# Accessor to get the device's service expiration date
sub
get_service_expiration
{
    my $self = shift;
    
    return $self->{ $STRING_SERVICE_EXPIRE };
}

# Accessor to get the device's warranty expiration
sub
get_warranty_expiration
{
    my $self = shift;
    
    return $self->{ $STRING_WARRANTY_EXPIRE };
}

# Accessor to determine whether a device is hidden
sub
get_hidden_status
{
    my $self = shift;
    
    return $self->{ $STRING_HIDDEN };
}

# Accessor to get the load average
sub
get_load_average
{
    my $self = shift;
    
    return $self->{ $STRING_LOAD_AVERAGE };
}

# Accessor to get the ZFS Version
sub
get_zfs_version
{
    my $self = shift;
    
    return $self->{ $STRING_ZFS_VERSION };
}

# Accessor to get the kernel versions
sub
get_kernel_version
{
    my $self = shift;
    
    return $self->{ $STRING_KERNEL_VERSION };
}

# Accessor to get the BIOS version
sub
get_bios_version
{
    my $self = shift;
    
    return $self->{ $STRING_BIOS_VERSION };
}

# Accessor to get the Virtual Box Version
sub
get_vbox_version
{
    my $self = shift;
    
    return $self->{ $STRING_VBOX_VERSION };
}

##
## All subs below this line should be considered private.  They are not guaranteed
## to remain in future releases of this module and should be used by other libraries
## with the understanding that they are "design by contract" for internal use by
## this library.
## 

# Sets the device's serial number, should be as a string.
sub
_priv_set_serial_number
{
    my $self = shift;
    
    $self->{ $STRING_SERIAL } = shift;
}

# Sets the device's hostname, as a string
sub
_priv_set_hostname
{
	my $self = shift;
	
	$self->{ $STRING_HOSTNAME } = shift;

}

# Sets the device's model number, as a string
sub
_priv_set_model
{
    my $self = shift;
    
    $self->{ $STRING_MODEL } = shift;
}

# Sets the amount of free space on the device, in KB
sub
_priv_set_free_space
{
    my $self = shift;
    
    $self->{ $STRING_FREESPACE } = shift;
}

# Sets the amount of used space on the device, in KB
sub
_priv_set_used_space
{
    my $self = shift;
    
    $self->{ $STRING_USEDSPACE } = shift;
}

# Sets the device's uptime, in seconds
sub
_priv_set_uptime
{
    my $self = shift;
    
    $self->{ $STRING_UPTIME } = shift;
}

# Sets the device's internal IP, as a string
sub
_priv_set_internal_ip
{
    my $self = shift;
    
    $self->{ $STRING_INTERNALIP } = shift;
}

# Sets the device's last checkin time, as a string.
sub
_priv_set_last_seen
{
    my $self = shift;
    
    $self->{ $STRING_LAST_SEEN } = shift;
}

# Sets the device's current upload speed.
sub
_priv_set_tx_limit_kb
{
    my $self = shift;
    
    $self->{ $STRING_TXLIMIT }
}

# Directly exposes the array of agents.  This should ONLY
# be used by other modules in this library as it does not make
# a copy.
#
# USE AT YOUR OWN RISK IN OUTSIDE CODE
sub
_priv_get_agents
{
	my $self = shift;
	
	return $self->{ $STRING_AGENTS };
}

# Sets the array of agents associated with this device
sub
_priv_set_agents
{
    my $self = shift;
    
    $self->{ $STRING_AGENTS } = shift;
}

# Sets the service expiration date
sub
_priv_set_service_expiration
{
    my $self = shift;
    
    $self->{ $STRING_SERVICE_EXPIRE } = shift;
}

# Sets the device's warranty expiration
sub
_priv_set_warranty_expiration
{
    my $self = shift;
    
    $self->{ $STRING_WARRANTY_EXPIRE } = shift;
}

# Sets whether a device is hidden
# Note that this module will ALWAYS return either TRUE or FALSE
# regardless of the internal values here.  This is because Agent objects
# are normally not created outside of a Collection (which pulls from the XML API)
sub
_priv_set_hidden_status
{
    my $self = shift;
    
    my $value = shift;
    
    if( $value == $TRUE )
    {
        $self->{ $STRING_HIDDEN } = $TRUE;
    }
    else
    {        
        $self->{ $STRING_HIDDEN } = $FALSE;
    }
}

# Sets the device's load average
sub
_priv_set_load_average
{
    my $self = shift;
    
    $self->{ $STRING_LOAD_AVERAGE } = shift;
}

# Sets the device's ZFS Version
sub
_priv_set_zfs_version
{
    my $self = shift;
    
    $self->{ $STRING_ZFS_VERSION } = shift;
}

# Sets the device's kernel version
sub
_priv_set_kernel_version
{
    my $self = shift;
    
    $self->{ $STRING_KERNEL_VERSION } = shift;
}

# Sets the device's BIOS version
sub
_priv_set_bios_version
{
    my $self = shift;
    
    $self->{ $STRING_BIOS_VERSION } = shift;
}

# Sets the device's Virtual Box Version
sub
_priv_set_vbox_version
{
    my $self = shift;
    
    $self->{ $STRING_VBOX_VERSION } = shift;
}

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

This module represents a physical (or virtual) Datto appliance and is an OO
way to represent its properties, such as hostname, IP, agents, etc.

=head1 METHODS

=head2 new

No arguments required.  All fields are set to undef.

Returns undef if there was an error fetching the XML.

=head2 get_serial_number

Returns the device's serial number

=head2 get_hostname

Returns the device's hostname

=head2 get_model

Returns the devices' model

=head2 get_free_space

Returns the free space (in KB) on the device

=head2 get_used_space

Returns the used space (in KB) on the device

=head2 get_uptime

Returns the uptime (in seconds) of the device

=head2 get_internal_ip

Returns the internal IP as a string.

=head2 get_last_seen

Returns the last time the device was seen, as a date string

For example, this would return "2014-07-31 22:05:04"

=head2 get_tx_limit_kb

Returns the current offsite transmit limit in KB

=head2 All other functions

All other functions in this module start with _priv and are designed to be use
within the module itself.  They are documented inline, but not part of the public
interface.  They are not guaranteed to remain in future releases.  The public functions
are guaranteed to remain.

=head1 CONFIGURATION

Backup::Datto::Device requires no configuration files or environment variables.

=head1 BUGS AND LIMITATIONS

This module assumes EST time.  Future versions will handle devices in multiple time zones

This module does not handle NAS Shares at this time.

There is very little error checking since this module is intended to be used
within the DattoCollection module.

=head1 AUTHOR

Matthew Topper, mtopper@cpan.org

=head1 LICENSE AND COPYRIGHT

Copyright (C), Matthew Topper.  All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

=cut

1;