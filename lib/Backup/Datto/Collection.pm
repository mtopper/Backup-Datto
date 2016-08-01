# DattoCollection.pm
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

package Backup::Datto::Collection;

# Boilerplate
use warnings;
use strict;
our $VERSION = "0.1.1";

# Modules that are part of this project
use Backup::Datto::Device;
use Backup::Datto::Agent;

# Modules that are outside of this project, but are required.
use XML::Simple;
use Time::Interval;
use Time::Piece;
use Time::Seconds;
use LWP;
use Data::Dumper;

# How many seconds constitute 'too long'.  This is 30 days by default
my $REBOOT_DURATION   = ONE_DAY * 30;

# Datto's XML shows a pre-1970 date to indicate NULL, or invalid.  This is in
# EST time
my $INVALID_DATE      = "1969-12-31 19:00:00";

# How long (in seconds) can an agent be offsite.
# The ONE_WEEK constant in this example is exported by Time::Seconds
my $OFFSITE_THRESHOLD = ONE_WEEK;

# How long (in seconds) can an agent be offline without an alarm
# The ONE_HOUR constant in this example is exported by Time::Seconds
my $OFFLINE_THRESHOLD = ONE_HOUR;

# How long (in seconds) can an agent go without a backup without alarming
# The ONE_DAY constant is exported by Time::Seconds
my $BACKUP_THRESHOLD  = ONE_DAY;

# The API Key used to dynamically download configuration data
my $STRING_API_KEY = 'API_KEY';

# The XML URL for Datto's servers - does not include the API Key
my $DATTO_XML_URL = 'http://partners.dattobackup.com/xml2.php?type=status&apiKey=';

# This string indicates a successful backup in Datto's response
my $SUCCESS_STATUS = 'Success';

# These strings represent how the XML value is presented
# in the downloaded file
my $XML_SERIAL          = 'SerialNumber';
my $XML_HOSTNAME        = 'Hostname';
my $XML_UPTIME          = 'Uptime';
my $XML_MODEL           = 'Model';
my $XML_FREESPACE       = 'FreeSpace';
my $XML_USEDSPACE       = 'UsedSpace';
my $XML_INTERNALIP      = 'InternalIP';
my $XML_TXLIMIT         = 'TxSpeedLimit';
my $XML_LAST_SEEN       = 'Lastseen';
my $XML_LAST_BACKUP     = 'LastBackup';
my $XML_LAST_STATUS     = 'LastBackupStatus';
my $XML_LAST_OFFSITE    = 'LatestOffsite';
my $XML_AGENT_TYPE      = 'Agent';
my $XML_AGENT           = 'Agent';
my $XML_BACKUP_VOLUMES  = 'BackupVolumes';
my $XML_BACKUP_VOLUME   = 'BackupVolume';
my $XML_CONTENT         = 'content';
my $XML_TYPE            = 'type';
my $XML_DEVICE          = 'Device';
my $XML_HIDDEN          = 'IsHidden';

# These strings are used to keep all hashes internally consistent.
my $STRING_AGENTS         = 'Agents';
my $STRING_DATTOS         = 'AllDattos';
my $STRING_REBOOTS        = 'RebootCount';
my $STRING_FAILED         = 'FailedAgents';
my $STRING_NUM_DATTOS     = 'NumberOfDattos';
my $STRING_BEHIND_OFFSITE = 'NumBehindOffsie';
my $STRING_XML            = 'DattoXML';
my $STRING_OFFLINE        = 'NumOffline';
my $STRING_BEHIND_LOCAL   = 'BehindLocal';
my $STRING_USED_HASH      = 'UsedHash';


# Creates a new collection of Datto objects from the XML API and populates
# some predefined metrics
# returns undef if there is a problem getting the XML.
sub
new
{
    my $class          = shift;
    my $api_key        = shift;
    
    my $self = {
        $STRING_DATTOS         => undef,
        $STRING_AGENTS         => 0,
        $STRING_REBOOTS        => undef,
        $STRING_FAILED         => undef,
        $STRING_NUM_DATTOS     => 0,
        $STRING_BEHIND_OFFSITE => undef,
        $STRING_XML            => undef,
        $STRING_OFFLINE        => undef,
        $STRING_BEHIND_LOCAL   => undef,
        $STRING_USED_HASH      => undef,
        $STRING_API_KEY        => $api_key
    };
    
    bless ($self, $class);
    
    # Get the XML file from Datto - abort if we can't get it.
    my $xml_result = $self->_priv_set_dattoXML();
    if( $xml_result == -1 )
    {
       return undef;
    }
    
    $self->_priv_set_api_key( $api_key );
    $self->_priv_get_all_dattos();
    $self->_priv_set_reboots();
    $self->_priv_set_failed();
    $self->_priv_set_behind_offsite();
    $self->_priv_set_offline();
    $self->_priv_set_behind_backup();
    
    return $self;
}

##
## Public methods
## These methods are guaranteed to exist in future versions
## of this module and to be called externally
##

# Returns the API Key.
sub
get_api_key
{
    my $self = shift;
    
    return $self->{ $STRING_API_KEY };
}

# Returns the number of devices that are in need of a reboot
# based on being up longer than $REBOOT_DURATION
sub
get_reboot_count
{
    my $self = shift;
    
    return $self->{ $STRING_REBOOTS };
}

# Returns the number of agents, across all devices, that need a reboot
sub
get_failed_agents
{
    my $self = shift;
    
    return $self->{ $STRING_FAILED };
}

# Returns the number of devices in this collection
sub
get_num_dattos
{
    my $self = shift;
    
    return $self->{ $STRING_NUM_DATTOS };
}

# Returns the number of agents, across all devices, that
# are behind in their offsite backup, with behind, being longer than
# OFFSITE_THRESHOLD
sub
get_behind_offsite
{
    my $self = shift;
    
    return $self->{ $STRING_BEHIND_OFFSITE };
}

# Get the raw XML data that the web service returned
sub
get_raw_xml
{
    my $self = shift;
    
    return $self->{ $STRING_XML };
}

# Returns the number of devices that are offline
sub
get_offline
{
    my $self = shift;
    
    return $self->{ $STRING_OFFLINE };
}

# Returns the number of agents that have not had a backup in $BACKUP_THRESHOLD
# This is 24 hours by default
sub
get_behind_local
{
    my $self = shift;
    
    # If the caller passed a value to compare with, calculate
    # the backup threshold with that value.
    if( defined $_[1] )
    {
        
    }
    
    return $self->{ $STRING_BEHIND_LOCAL };
}

# Returns the number of agents in the collection
sub
get_num_agents
{
    my $self = shift;
    
    return $self->{ $STRING_AGENTS };
}


# Returns a hash containing the used space of each device, by hostname
# This creates a new hash each time, to avoid passing a reference
# to a private data structure.
sub
get_used_hash
{
    my $self = shift;
    
    my %space_hash = ();
    
    foreach my $datto( @{ $self->{ $STRING_DATTOS } } )
    {
        $space_hash{ $datto->get_hostname() } = $datto->get_used_space();
    }
    
    return \%space_hash;
}

##
## All subs below this line should be considered private.  They are not guaranteed
## to remain in future releases of this module and should be used by other libraries
## with the understanding that they are "design by contract" for internal use by
## this library.
## 


# Records the collection's API Key, which is unique
# for each partner.
sub
_priv_set_api_key
{
    my $self = shift;
    
    $self->{ $STRING_API_KEY } = shift;
}

# Calculates the number of devices in need of a reboot
# based on the value of REBOOT_DURATION
sub
_priv_set_reboots
{
    my $self = shift;
    
    my $num_reboots = 0;
    
    foreach my $datto ( @{ $self->_priv_get_dattos() } )
    {
        if( $datto->get_uptime() >= $REBOOT_DURATION )
        {
            $num_reboots += 1;
        }
    }
    
    $self->{ $STRING_REBOOTS } = $num_reboots;
}

# Accessor method to set the array of Dattos.
sub
_priv_set_dattos
{
    my $self   = shift;
    my $dattos = shift;
    
    $self->{ $STRING_DATTOS } = $dattos;
}

# Accessor method to set the array of Datto devices.
sub
_priv_get_dattos
{
    my $self = shift;
    
    return $self->{ $STRING_DATTOS };
}

# This function is responsible for parsing the XML file and creating
# the Datto objects.  
sub
_priv_get_all_dattos
{
    my $self    = shift;
    my $api_key = $self->get_api_key();
    
    # Get the XML from Datto's site.  Placeholder for now
    my $config = XMLin( $self->get_raw_xml(), forcearray => [ $XML_BACKUP_VOLUME ] );

    
    my @dattos = ();
    
    foreach my $device ( @{ $config->{ $XML_DEVICE } } )
    {
        my $device_object = new Backup::Datto::Device();
        
        # Check if it's something that is hidden in the portal
        if( $device->{ $XML_HIDDEN } != 0 )
        {
            next;
        }
        
        # Note that these _priv functions are private.  Outside code should
        # call them at its own risk
        $device_object->_priv_set_serial_number( $device->{ $XML_SERIAL     } );
        $device_object->_priv_set_hostname(      $device->{ $XML_HOSTNAME   } );
        $device_object->_priv_set_uptime(        $device->{ $XML_UPTIME     }->{ $XML_CONTENT } );
        $device_object->_priv_set_model(         $device->{ $XML_MODEL      } );
        $device_object->_priv_set_free_space(    $device->{ $XML_FREESPACE  }->{ $XML_CONTENT } );
        $device_object->_priv_set_used_space(    $device->{ $XML_USEDSPACE  }->{ $XML_CONTENT } );
        $device_object->_priv_set_internal_ip(   $device->{ $XML_INTERNALIP } );
        $device_object->_priv_set_tx_limit_kb(   $device->{ $XML_TXLIMIT    }->{ $XML_CONTENT } ); 
        $device_object->_priv_set_last_seen(     $device->{ $XML_LAST_SEEN  }->{ $XML_CONTENT } );
                      
        # For each Datto device, add all of the agents
        $self->_priv_create_agents( $device_object, $device->{ $XML_BACKUP_VOLUMES }->{ $XML_BACKUP_VOLUME } );
        
        # TODO: Don't access this directly
        $self->{ $STRING_NUM_DATTOS } += 1;
        
        push ( @dattos, $device_object );
    }
    
    $self->_priv_set_dattos( \@dattos );
}

# This function is responsible for creating the agent objects that are associated with each Datto
# device.
sub
_priv_create_agents
{
    my $self    = shift;
    my $device  = shift;
    my $agents  = shift;
    
    my @agents = ();
    
    foreach my $server ( @$agents )
    {
        my $agent = new Backup::Datto::Agent();
        
        # Skip other types of agents like NAS Shares
        # a future version of this module may handle this correctly
        if( $server->{ $XML_TYPE } ne $XML_AGENT_TYPE )
        {
            next;
        }
        
        $agent->_priv_set_agent_name(   $server->{ $XML_AGENT        } );
        $agent->_priv_set_last_backup(  $server->{ $XML_LAST_BACKUP  }->{ $XML_CONTENT } );
        $agent->_priv_set_last_status(  $server->{ $XML_LAST_STATUS  } );
        $agent->_priv_set_last_offsite( $server->{ $XML_LAST_OFFSITE }->{ $XML_CONTENT } );
        
        push( @agents, $agent );
        
        # TODO: Don't access this directly
        $self->{ $STRING_AGENTS } += 1;
    }
    
    $device->_priv_set_agents( \@agents );
}

# This function calculates the number of agents that failed.
sub
_priv_set_failed
{
    my $self = shift;
    
    my $num_failed = 0;
    
    foreach my $datto ( @{ $self->{ $STRING_DATTOS } } )
    {
        foreach my $agent ( @{ $datto->_priv_get_agents() } )
        {   
            if( $agent->get_last_status() ne $SUCCESS_STATUS )
            {
                $num_failed += 1;
            }
        }
    }
    
    $self->{ $STRING_FAILED } = $num_failed;
}

# Calculate how many agents are behind on offsite transfer
sub
_priv_set_behind_offsite
{
    my $self = shift;
    
    my $num_behind = 0;
    
    # Get the current time into a format that Time::Interval can understand
    # localtime returns the time as the following fields (all are numeric)
    # it is okay that the values do not have leading zeros
    # Note that the month is zero indexed (January is 0), so 1 is added
    # localtime returns the year 2001 as 101, which is why 1900 is added
    # the target format is: 2014-07-31 22:05:04
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime( time() );
    my $now = $year + 1900 . "-" . (  $mon + 1 )  . "-$mday $hour:$min:$sec";
    
 
    foreach my $datto ( @{ $self->{ $STRING_DATTOS } } )
    {
        foreach my $agent ( @{ $datto->_priv_get_agents() } )
        {
            # Check if it's never been offsite at all.
            # This can indicate either a new device, or a device at a client
            # with a failed Internet connection.  This is important because
            # as of 9/2014, Datto represents this as a pre-1970 date, which
            # will cause the Date parser to fail.
            if( $agent->get_last_offsite() eq $INVALID_DATE )
            {
                $num_behind += 1;
                next;
            }

            # Determine the interval between the last backup
            # and the date string from earlier
            my $interval = getInterval ( $agent->get_last_offsite(), $now );
            
            # Convert that interval to seconds.  This apparently cannot
            # take a Time::Interval reference so the individual fields
            # are passed.  See Time::Interval's POD for more information
            my $number_of_seconds = convertInterval (
                days        => $interval->{ 'days'    },
                hours       => $interval->{ 'hours'   },
                minutes     => $interval->{ 'minutes' },
                seconds     => $interval->{ 'seconds' },
                ConvertTo   => "seconds" );
            
            if( $number_of_seconds > $OFFSITE_THRESHOLD )
            {
                $num_behind += 1;
            }
        }
    }
    
    $self->{ $STRING_BEHIND_OFFSITE } = $num_behind;
}

# Calculate how many devices are offline
# Offline is considered more than OFFLINE_THRESHOLD
sub
_priv_set_offline
{
    my $self = shift;
    
    my $num_offline = 0;
    
    # Get the current time into a format that Time::Interval can understand
    # localtime returns the time as the following fields (all are numeric)
    # it is okay that the values do not have leading zeros
    # Note that the month is zero indexed (January is 0), so 1 is added
    # localtime returns the year 2001 as 101, which is why 1900 is added
    # the target format is: 2014-07-31 22:05:04
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime( time() );
    my $now = $year + 1900 . "-" . (  $mon + 1 )  . "-$mday $hour:$min:$sec";
  
    
    foreach my $datto ( @{ $self->{ $STRING_DATTOS } } )
    {   
    
        # Check if it's checked in at all.
        # This can indicate either a new device.  This is important because
        # as of 9/2014, Datto represents this as a pre-1970 date, which
        # will cause the Date parser to fail.
        if( $datto->get_last_seen() eq $INVALID_DATE )
        {
            $num_offline += 1;
            next;
        }
        # Determine the interval between what the Datto reports
        # as its last checkin time and the date string from earlier
        my $interval = getInterval ( $datto->get_last_seen(), $now );
         
        # Convert that interval to seconds.  This apparently cannot
        # take a Time::Interval reference so the individual fields
        # are passed.  See Time::Interval's POD for more information
        my $number_of_seconds = convertInterval (
            days        => $interval->{ 'days'    },
            hours       => $interval->{ 'hours'   },
            minutes     => $interval->{ 'minutes' },
            seconds     => $interval->{ 'seconds' },
            ConvertTo   => "seconds" );
        
       
        # If the last checkin was longer than the OFFLINE_THRESHOLD seconds,
        # consider the device as offline
        if( $number_of_seconds > $OFFLINE_THRESHOLD )
        {
             $num_offline += 1;
        }
        
    }
     
    $self->{ $STRING_OFFLINE } = $num_offline;
    
}


# Determines how many agents are behind on local backups
# Behind is considered anything longer than $BACKUP_THRESHOLD
sub
_priv_set_behind_backup
{
    my $self = shift;
    
    my $num_behind = 0;
    
    # Get the current time into a format that Time::Interval can understand
    # localtime returns the time as the following fields (all are numeric)
    # it is okay that the values do not have leading zeros
    # Note that the month is zero indexed (January is 0), so 1 is added
    # localtime returns the year 2001 as 101, which is why 1900 is added
    # the target format is: 2014-07-31 22:05:04
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime( time() );
    my $now = $year + 1900 . "-" . (  $mon + 1 )  . "-$mday $hour:$min:$sec";
    
 
    foreach my $datto ( @{ $self->{ $STRING_DATTOS } } )
    {
        foreach my $agent ( @{ $datto->_priv_get_agents() } )
        {
            # Check if it's never been offsite at all.
            # This can indicate either a new device, or a device at a client
            # with a failed Internet connection.  This is important because
            # as of 9/2014, Datto represents this as a pre-1970 date, which
            # will cause the Date parser to fail.
            if( $agent->get_last_backup() eq $INVALID_DATE )
            {
                $num_behind += 1;
                next;
            }

            # Determine the interval between the last backup
            # and the date string from earlier
            my $interval = getInterval ( $agent->get_last_backup(), $now );
            
            # Convert that interval to seconds.  This apparently cannot
            # take a Time::Interval reference so the individual fields
            # are passed.  See Time::Interval's POD for more information
            my $number_of_seconds = convertInterval (
                days        => $interval->{ 'days'    },
                hours       => $interval->{ 'hours'   },
                minutes     => $interval->{ 'minutes' },
                seconds     => $interval->{ 'seconds' },
                ConvertTo   => "seconds" );
            
            if( $number_of_seconds > $BACKUP_THRESHOLD )
            {
                $num_behind += 1;
            }
        }
    }
    
    $self->{ $STRING_BEHIND_LOCAL } = $num_behind;
    
}

# Retrieves the XML status from the Datto web interface
# Returns 0  for success
# Returns -1 for failure
sub
_priv_set_dattoXML
{
    my $self = shift;
    
    my $status = 0;
    
    my $user_agent = LWP::UserAgent->new();
    my $request    = HTTP::Request->new( GET => $DATTO_XML_URL . $self->get_api_key() );
    my $result     = $user_agent->request( $request );
    
    if( $result->is_success() )
    {
        $self->{ $STRING_XML } = $result->content;
    }
    else
    {
        $status = -1;
    }
    
    return $status;
}


1;

__END__

=head1 NAME

Backup::Datto::Collection - Report status information on all of the Datto backup devices owned by an organization.

=head1 VERSION

This document describes DattoCollention version 0.1.1

=head1 SYNOPSIS

my $datto_collection = new Backup::Datto::Collection( 'dymr1gc0bvbinik88p5gkql4x4xexzkc' );

print $datto_collection->get_reboot_count() . " devices need a reboot\n";
print $datto_collection->get_failed_agents() . " agents failed their last backup\n";
print $datto_collection->get_behind_offsite() . " agents are behind for offsite\n";
print $datto_collection->get_offline() . " devices are offline\n";
print $datto_collection->get_behind_local() . " devices have not had a backup in 24 hours.\n";

=head1 DESCRIPTION

This module reports status information on all the Datto appliances in an MSPs fleet.

This came about from the need to feed status information on all of the devices to other
monitoring tools for display purposes.

It handles the calculation for all of the items I wanted to initially display.

=head1 METHODS

=head2 new

Takes the API key (available from the partner portal) and fetches the XML configuration.
This also processes the XML and prefills all of the values that the later functions return.
Note that this means that values are not recalculated on subsequent calls to the get functions.

Returns undef if there was an error fetching the XML.

=head2 get_api_key

Returns the Datto API Key used during this session.

=head2 get_reboot_count

Returns the number of appliances that need a reboot.  This is determined by
the device being up for more than REBOOT_DURATION, a constant set
to 30 days by by default.  Future versions of this module will include the
ability to modify this.

=head2 get_failed_agents

Returns the number of agents that failed their last backup.

=head2 get_num_dattos

Returns the number of appliances in the collection.

=head2 get_num_agents

Returns the number of agents in the collection

=head2 get_used_space

Returns a hash containing the used space of each device, by hostname

=head2 get_behind_offsite

Returns the number of agents that are behind on their offsite backup.  This is
determined by the agent not sending an image offsite for more than OFFSITE_THRESHOLD.
By default, this is one week.  Future versions of this module will include the ability
to modify this.

=head2 get_behind_local

Returns the number of agent that are behind on local backups.  This is determined by
checking the last successful onsite backup.  This is checked against the value of
BACKUP_THRESHOLD which is set to 24 hours by default.  Future versions of this module
will include the ability to modify this.

=head2 get_offline

Returns the number of agents that are offline.  This is determined by comparing the last
checkin time with the current time and comparing the difference with OFFLINE_THRESHOLD.
By default, this threshold is set to 1 hour.  Future versions of this module will
include the ability to modify this.

=head2 get_raw_xml

Returns the raw XML from Datto's API as a string.  This can be used for diagnostic
purposes, or to pass to other programs.

=head2 get_used_hash

Returns a hash containing the amount of used space, in KB, for each device.  The keys are hostnames.

=head2 All other functions

All other functions in this module start with _priv and are designed to be use
within the module itself.  They are documented inline, but not part of the public
interface.  They are not guaranteed to remain in future releases.  The public functions
are guaranteed to remain.

=head1 CONFIGURATION

Baclup::Datto::Collection requires no configuration files or environment variables.

=head1 BUGS AND LIMITATIONS

This module assumes EST time.  Future versions will handle devices in multiple time zones

This module does not handle NAS Shares at this time.

=head1 AUTHOR

Matthew Topper, mtopper@cpan.org

=head1 LICENSE AND COPYRIGHT

Copyright (C), Matthew Topper.  All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

=cut