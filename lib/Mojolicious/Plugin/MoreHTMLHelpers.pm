package Mojolicious::Plugin::MoreHTMLHelpers;

# ABSTRACT: Some general helpers

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = 0.02;

sub register {
    my ($self, $app, $config) = @_;

    $app->helper( textcolor => sub {
        my $c = shift;

        my $color = shift // '#000000';

        my ($red, $green, $blue);

        if ( length $color == 7 ) {
            ($red, $green, $blue) = $color =~ m{\#(..)(..)(..)};
        }
        elsif ( length $color == 4 ) {
            ($red, $green, $blue) = $color =~ m{\#(.)(.)(.)};
            for ( $red, $green, $blue ) {
                $_ = $_ x 2;
            }
        }

        my $brightness = _perceived_brightness( $red, $green, $blue );

        return $brightness > 130 ? '#000000' : '#ffffff';
    } );

    $app->helper( gradient => sub {
        my ($c) = shift;

        my $color = shift // '#ffffff';

        return sprintf q~
            background: %s !important;
            background: -moz-linear-gradient(top,  %s 0%%,%s 100%%) !important;
            background: -webkit-gradient(linear, left top, left bottom, color-stop(0%%, %s), color-stop(100%%,%s)) !important;
            background: -webkit-linear-gradient(top,  %s 0%%,%s 100%%) !important;
            background: -o-linear-gradient(top,  %s 0%%,%s 100%%) !important;
            background: -ms-linear-gradient(top,  %s 0%%,%s 100%%) !important;
            background: linear-gradient(to bottom,%s 0%%,%s 100%%) !important;
        ~, ($color) x 13;
    });
}

sub _perceived_brightness {
    my ($red, $green, $blue) = @_;

    if ( grep { !defined $_ || $_ =~ m{[^A-Fa-f0-9]} }($red, $green, $blue) ) {
        return 200;
    }

    $red   = hex $red;
    $green = hex $green;
    $blue  = hex $blue;

    my $brightness = int ( sqrt (
        ( $red   * $red   * .299 ) +
        ( $green * $green * .587 ) +
        ( $blue  * $blue  * .114 )
    ));

    return $brightness;
}

1;

=head1 SYNOPSIS

In your C<startup>:

    sub startup {
        my $self = shift;
  
        # do some Mojolicious stuff
        $self->plugin( 'MoreHTMLHelpers' );

        # more Mojolicious stuff
    }

In your template:

    <span style="color: <% textcolor('#135713') %>">Any text</span>

=head1 HELPERS

This plugin adds a helper method to your web application:

=head2 textcolor

This method requires at least one parameter: The color the text color is based on.
The text color should have a contrast to the background color. In web apps where
the user can define its own color set, it's necessary to calculate the textcolor
on the fly. This is what this helper is for.

    <span style="background-color: #135713; color: <% textcolor('#135713') %>">Any text</span>

=head2 gradient

This creates the CSS directives for a gradient

    <style>
        .black-gradient { <%= gradient('#000000') %> }
    </style>

will be

    <style>
        .black-gradient {
            background: #000000 !important;
            background: -moz-linear-gradient(top,  #000000 0%,#000000 100%) !important;
            background: -webkit-gradient(linear, left top, left bottom, color-stop(0%, #000000), color-stop(100%,#000000)) !important;
            background: -webkit-linear-gradient(top,  #000000 0%,#000000 100%) !important;
            background: -o-linear-gradient(top,  #000000 0%,#000000 100%) !important;
            background: -ms-linear-gradient(top,  #000000 0%,#000000 100%) !important;
            background: linear-gradient(to bottom,#000000 0%,#000000 100%) !important;
    }
    </style>

=head1 METHODS

=head2 register

Called when registering the plugin. On creation, the plugin accepts a hashref to configure the plugin.

    # load plugin, alerts are dismissable by default
    $self->plugin( 'MoreHTMLHelpers' );

