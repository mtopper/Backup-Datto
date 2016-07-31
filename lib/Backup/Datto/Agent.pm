# Agent.pm
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

package Backup::Datto::Agent;

# Boilerplate
use warnings;
use strict;
our $VERSION = "0.1.1";

# These constants are the field names in Datto's XML.  If Datto changes
# them, this is the only section of code you will need to modify.
my $STRING_AGENT_NAME    = 'Agent';
my $STRING_LAST_OFFISTE  = 'Hostname';
my $STRING_LAST_BAKCUP   = 'LastBackup';
my $STRING_LAST_STATUS   = 'LastBackupStatus';

sub
new
{
    my $class = shift;
    
    my $self  = {
        $STRING_AGENT_NAME   => undef,
        $STRING_LAST_BAKCUP  => undef,
        $STRING_LAST_OFFISTE => undef,
        $STRING_LAST_STATUS  => undef
    };
	
	bless( $self, $class );
	
	return $self;
}

##
## Public methods
## These methods are guaranteed to exist in future versions
## of this module and to be called externally
##

# Returns the agent's hostname as a string
sub
get_agent_name
{
    my $self = shift;
    
    return $self->{ $STRING_AGENT_NAME };
}

# Returns the time of the last backup, as a string
sub
get_last_backup
{
    my $self = shift;
    
    return $self->{ $STRING_LAST_BAKCUP };
}

# Returns the time of the last time this agnet synced offsite
sub
get_last_offsite
{
    my $self = shift;
    
    return $self->{ $STRING_LAST_OFFISTE };
}

# Returns the last status of the agent, as a string
# as an example, this might be 'Success' or 'Failed'
sub
get_last_status
{
	my $self = shift;
	
	return $self->{ $STRING_LAST_STATUS };
}

##
## All subs below this line should be considered private.  They are not guaranteed
## to remain in future releases of this module and should be used by other libraries
## with the understanding that they are "design by contract" for internal use by
## this library.
## 

# Sets the agent's hostname
sub
_priv_set_agent_name
{
    my $self = shift;
    
    $self->{ $STRING_AGENT_NAME} = shift;
}

# Sets the time of the agent's last backup
sub
_priv_set_last_backup
{
    my $self = shift;
    
    $self->{ $STRING_LAST_BAKCUP } = shift;    
}

# Sets the time of the agent's last offsite.
sub
_priv_set_last_offsite
{
    my $self = shift;
    
    $self->{ $STRING_LAST_OFFISTE } = shift;
}

# Sets the last status of the agent
sub
_priv_set_last_status
{
	my $self = shift;
	
	$self->{ $STRING_LAST_STATUS } = shift;
}


1;

__END__

=head1 NAME

Backup::Datto::Agent - A module representing an agent on a Datto object

=head1 VERSION

This document describes Datto version 0.1.1.  It is designed to be used by the
DattoCollection class, and as a result, most of its interface is not public.

=head1 SYNOPSIS

Note:  This is not useful without something setting the values below.
See DattoCollection.pm for more details

my $dattoagent = new Datto::Agent();


=head1 DESCRIPTION

This module represents an agent on a Datto appliance.  Most commonly, this is
a windows server, but can also be a NAS share.  Note that NAS shares are not
supported yet.

=head1 METHODS

=head2 new

No arguments required.  All fields are set to undef.

=head2 get_agent_name

Returns the agent's name.  This will normally be the hostname.

=head2 get_last_backup

Returns the time of the last backup, as a date string: "2014-07-31 22:05:04"

Note that Datto's API uses "1969-12-31 19:00:00" to represent the agent never completing
a backup.

=head2 get_last_offsite

Returns the time of the last offsite, as a date string: "2014-07-31 22:05:04"

Note that Datto's API uses "1969-12-31 19:00:00" to represent tha agent never completing
an offsite backup.

=head2 get_last_status

Returns the status of the last backup as a string.  This is pulled directly
from Datto's API and passed through.  As an example, this will return the word
"Success" for success.  This method is guaranteed to remain constant, but a future
version of this module may return a status value.

=head2 All other functions

All other functions in this module start with _priv and are designed to be use
within the module itself.  They are documented inline, but not part of the public
interface.  They are not guaranteed to remain in future releases.  The public functions
are guaranteed to remain.

=head1 CONFIGURATION

Datto::Agent requires no configuration files or environment variables.

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