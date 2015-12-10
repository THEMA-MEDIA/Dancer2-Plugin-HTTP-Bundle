use Dancer2;
use lib '../../lib';
use Dancer2::Plugin::HTTP;

=pod
 
This test shows that the order of content_types_provided
is actually important if you do not specify a media-type.
 
# JSON is the default ...
curl -v http://0:3000/
 
# you must ask specifically for HTML
curl -v http://0:3000/ -H 'Accept: text/html'
 
# but open in a browser and you get HTML
open http://0:3000/
 
=cut

get '/' => sub {
    http_choose (
        'application/json' => sub {my_json()},
        'text/html'        => sub {my_html()},
        { default => undef }
    )
};

sub my_json {to_json({ message => 'Hello World' })};
sub my_html {'<html><body><h1>Hello World</h1></body></html>'}

dance;