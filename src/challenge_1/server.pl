#!/usr/bin/perl

use strict;
use warnings;

use API;
use threads ('yield',
    'stack_size' => 64*4096,
    'exit' => 'threads_only',
    'stringify'
);
use HTTP::Server::Brick;

sub remove_sessions_periodically {
    while (1) {
        `find ./sessions -mindepth 1 -amin +10 -exec rm -rf {} \\;`;
        sleep 10;
    }
}
my $thr = threads->create('remove_sessions_periodically');

my $server = HTTP::Server::Brick->new( port => 8080, timeout => 0.1, fork => 1);

$server->mount( '/api/login' => {
    handler => \&API::login,
    wildcard => 0,
});

$server->mount( '/api/user_info' => {
    handler => \&API::user_info,
    wildcard => 0,
});

$server->mount( '/api/register' => {
    handler => \&API::register,
    wildcard => 0,
});

$server->mount( '/api/comment' => {
    handler => \&API::comment,
    wildcard => 0,
});

$server->mount( '/api/comments' => {
    handler => \&API::comments,
    wildcard => 0,
});

$server->mount( '/api/post' => {
    handler => \&API::post,
    wildcard => 0,
});

$server->mount( '/api/posts' => {
    handler => \&API::posts,
    wildcard => 0,
});

$server->mount( '/api/logout' => {
    handler => \&API::logout,
    wildcard => 0,
});

$server->mount( '/' => {
    path => './',
});

$server->start;
