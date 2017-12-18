package API;

use strict;
use warnings;
use Exporter;
use JSON;
use Try::Tiny;
use URI::QueryParam;
use HTTP::Request;
use HTTP::Response;
use Path::Resolve;
use CGI::Cookie;
use Digest::MD5; 


use Database;

our @ISA = qw( Exporter );
our @EXPORT = qw( login register posts post comments comment logout );

my $SESSION_DIR = "./sessions";
my $json = JSON->new->allow_nonref;

sub get_session_file {
	my $session_id = shift;
	my $p = Path::Resolve->new;
	return $p->join($SESSION_DIR, "${session_id}.sess");
}

sub get_user_id_from_request {
	my $req = shift;
	my %cookie = CGI::Cookie->parse($req->header("Cookie"));
	if (exists $cookie{'SESSION_ID'}) {
		my $session_id = $cookie{'SESSION_ID'}->value;
		try {
			open(my $f, get_session_file($session_id));
			my $session_data = $json->decode(<$f>);
			return %$session_data{"user_id"};
		} catch {
			warn $_;
			return -1;
		}
	} else {
		return -1;
	}
}

sub get_session_id {
	my $req = shift;
	my %cookie = CGI::Cookie->parse($req->header("Cookie"));
	$cookie{'SESSION_ID'}->value;
}

sub set_response {
	my ($res, $code, %msg) = @_;
	if (%msg) {
		$res->add_content($json->encode(\%msg));
	}
	$res->header('Content-type', 'application/json');
	$res->code($code);
	1;
}

sub set_cookie {
	my ($user_id, $res) = @_;
	my $session_id = Digest::MD5::md5_hex(rand);
	my $cookie = CGI::Cookie->new(-name=>'SESSION_ID',-value=>$session_id);
	$res->header("Set-Cookie", $cookie->as_string);
	open(my $f, ">", get_session_file($session_id));
	my %session_data = ( user_id=>$user_id);
	print $f $json->encode(\%session_data);
}

sub login {
	my ($req, $res) = @_;
	if ($req->method ne "POST"){
		return set_response($res, 400);
	};
	my $db = Database->new;
	try {
		my $json_data = $json->decode($req->content);
		my $username = %$json_data{"username"}; 
		my $password = %$json_data{"password"};
		try {
			my $user_id = $db->get_user_id($username, $password);
			$db->close;
			if ($user_id != -1){
				my %msg = ( "status" => "true" );
				set_cookie($user_id, $res);
				return set_response($res, 200, %msg);
			}
			return set_response($res, 401);
		} catch {
			$db->close;
			warn $_;
			return set_response($res, 500);
		};
	} catch {
		warn $_;
		return set_response($res, 401)
	}
}

sub user_info {
	my ($req, $res) = @_;
	my $user_id = get_user_id_from_request($req);
	if ($user_id == -1){
		return set_response($res, 401);
	} else {
		my $db = Database->new;
		my %msg = $db->get_user_info($user_id);
		$db->close;
		return set_response($res, 200, %msg);
	}
}

sub register {
	my ($req, $res) = @_;
	if ($req->method ne "POST"){
		return set_response($res, 400);
	};
	my $db = Database->new;
	try {
		my $json_data = $json->decode($req->content);
		my $username = %$json_data{"username"}; 
		my $password = %$json_data{"password"};
		if ($db->register_user($username, $password)){
			my %msg = ( "status" => "true" );
			$db->close;
			return set_response($res, 200, %msg);
		} else {
			$db->close;
			return set_response($res, 400);
		}
	} catch {
		$db->close;
		warn $_;
		return set_response($res, 400);
	};
}

sub post {
	my ($req, $res) = @_;
	my $post_id = int $req->uri->query_param('post_id');
	my $db = Database->new;
	my %post_data = $db->get_post($post_id);
	$db->close;
	if (%post_data) {
		return set_response($res, 200, %post_data);
	} else {
		return set_response($res, 404);
	}
}

sub posts {
	my ($req, $res) = @_;
	my $page = int $req->uri->query_param('page');
	if ($page < 0) {
		$page = 0;
	}
	my $db = Database->new;
	my @posts = $db->get_posts($page);
	$db->close;
	my %msg = ("posts" => @posts);
	return set_response($res, 200, %msg);
}

sub comments {
	my ($req, $res) = @_;
	my $page = int $req->uri->query_param('page');
	my $post_id = int $req->uri->query_param('post_id');
	if ($page < 0) {
		$page = 0;
	}
	my $db = Database->new;
	my @comments = $db->get_comments($post_id, $page);
	$db->close;
	my %msg = ("comments" => @comments);
	return set_response($res, 200, %msg);
}

sub comment {
	my ($req, $res) = @_;
	if ($req->method ne "POST"){
		return set_response($res, 400);
	};
	my $user_id = get_user_id_from_request($req);
	if ($user_id == -1) {
		return set_response($res, 401);
	} else {
		my $db = Database->new;
		try {
			my $json_data = $json->decode($req->content);
			my $post_id = %$json_data{"post_id"}; 
			my $content = %$json_data{"content"};
			if ($db->save_comment($user_id, $post_id, $content)){
				my %msg = ( "status" => "true" );
				$db->close;
				return set_response($res, 200, %msg);
			} else {
				$db->close;
				return set_response($res, 400);
			}
		} catch {
			$db->close;
			warn $_;
			return set_response($res, 400);
		};
	}
}

sub logout {
	my ($req, $res) = @_;
	my $session_id = get_session_id($req);
	if ($session_id){
		unlink(get_session_file($session_id));
	}
	return set_response($res, 200);
}

1;