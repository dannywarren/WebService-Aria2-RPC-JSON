package WebService::Aria2::RPC::JSON;

use Moose;
extends 'WebService::Aria2::RPC';

use JSON::RPC::Common;
use JSON::RPC::Common::Marshal::HTTP;
use LWP::UserAgent;
use URI;


#############################################################################
# Meta
#############################################################################

our $VERSION = '0.01';


#############################################################################
# Public Accessors
#############################################################################

has uri => 
( 
  is      => 'rw', 
  isa     => 'Str', 
  default => 'http://localhost:6800/jsonrpc',
);


#############################################################################
# Private Accessors
#############################################################################

has counter => 
(
  is       => 'rw', 
  isa      => 'Int',
  default  => 0,
);

has rpc => 
(
  is         => 'rw', 
  isa        => 'JSON::RPC::Common::Marshal::HTTP',
  lazy_build => 1,
);

has ua => 
(
  is         => 'rw', 
  isa        => 'LWP::UserAgent',
  lazy_build => 1,
);


#############################################################################
# Object Methods
#############################################################################

# Initialize the rpc client instance
sub _build_rpc 
{
  my ( $self ) = @_;

  my $rpc = JSON::RPC::Common::Marshal::HTTP->new();

  return $rpc;
}

# Initialize the lwp ua instance
sub _build_ua 
{
  my ( $self ) = @_;

  my $ua = LWP::UserAgent->new();

  return $ua;
}


#############################################################################
# Public Methods
#############################################################################

# Base method for talking to aria2 via json-rpc
sub call
{
  my ( $self, $method, @params ) = @_;

  # Initialize the rpc if not already done
  if ( ! defined $self->rpc )
  {
    $self->init;
  }

  # Pass along the secret token if one exists
  if ( defined $self->secret )
  {
    # Add the secret token to the front of the parameters list
    unshift @params, $self->secret_token;
  }

  # Increment the request counter
  $self->_increment_counter;

  # Create a json-rpc call from our request info
  my $json_request = JSON::RPC::Common::Procedure::Call->inflate
  ({
    id     => $self->counter,
    method => $method,
    params => \@params,
  });

  # Create an http request object out of the json-rpc call
  my $request = $self->rpc->call_to_request
  (
    $json_request,
    uri => URI->new( $self->uri ),
  );

  # Post the request to the server
  my $response = $self->ua->request( $request );

  # Handle any http errors
  if ( $response->is_error )
  {
    warn sprintf "ERROR: %s\n", $response->status_line;
    return;
  }

  # Parse the response to json data
  my $json_result = $self->rpc->response_to_result( $response );

  # Handle errors returned from rpc processing
  if ( defined $json_result->{error} )
  {
    # Display error and bail
    warn sprintf "ERROR: %s\n", $json_result->{error};
    return;
  }

  # Finally, return the json result data
  return $json_result->result;
}


#############################################################################
# Private Methods
#############################################################################

# Increment the request counter
sub _increment_counter
{
  my ( $self ) = @_;

  # Bump the counter
  $self->counter( $self->counter + 1 );

  return;
}


1;
