# Dancer2-Plugin-HTTP
The missing bits in Dancer2 to make a proper REST API

# SYNOPSIS
There are a few Dancer2 Plugins to help building REST api's. This wrapper helps
loading them all at once, in the right order and will demonstrate the combined
use of them.

    use Dancer2::Plugin::HTTP
    
    get '/secrets/:id' => http_auth_handler_can('find_something') => sub {
        my $secret_object = http_auth_handler->find_something(param->{id})
            or return sub { status (404 ) };
        http_conditional (
            etag            => $secret_object->etag,
            last_modified   => $secret_object->date_last_modified
        ) =>sub { http_choose_accept (
            'application/json' => sub { to_json $secret_object },
            'application/xml'  => sub { to_xml  $secret_object },
            { default => undef }
        ) }
    };

Or a little more verbose

    use Dancer2::Plugin::HTTP
    
    get '/secrets/:id' => http_handler_can('find_something') => sub {
        
        # what content-type does the client want
        http_choose_accept (
            
            [ 'application/json', 'application/xml' ] => sub {
                    
                # find the resource
                
                my $secret_object =
                    http_handler->find_something(param->{id});
                
                unless ( $secret_object ) {
                    status (404); # Not Found
                    return;
                }
                
                # set caching information
                
                http_cache_max_age 3600;
                http_cache_private;
                
                # make the request conditional
                # maybe we do not need to serialize
                
                http_conditional (
                    etag            => $secret_object->etag,
                    last_modified   => $secret_object->date_last_modified
                ) => sub {
                    for (http_accept) {
                        when ('application/json') {
                            return to_json ( $secret_object )
                        }
                        when ('application/xml') {
                            return to_xml ( $secret_object )
                        }
                    }
                }
                
            },
            
            [ 'image/png', 'image/jpeg' ] => sub {
                ...
            },
            
            { default => undef }
        )
        
    };


# head1 HTTP... and the RFC's

## RFC 7234 - Hypertext Transfer Protocol (HTTP/1.1): Caching

The Hypertext Transfer Protocol (HTTP) is a stateless application-
level protocol for distributed, collaborative, hypertext information
systems.  This document defines HTTP caches and the associated header
fields that control cache behavior or indicate cacheable response
messages.

_Dancer2::Plugin::HTTP::Caching_

