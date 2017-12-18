package Database;
use DBI;
use Exporter;

our @ISA = qw( Exporter );
our @EXPORT = qw( get_user_id register_user get_posts get_post );

my $db_host = "localhost";
my $db_port = "3306";
my $db_user = "whitehat1";
my $db_password = "7156823d1e463e1813a8da4786f06b7659a34ad539262cade785484dddcb090b";
my $db_name = "whitehat1";

my $POSTS_PER_PAGE = 5;
my $COMMENTS_PER_PAGE = 10;

sub new {
	my $class = shift;
	my $dsn = "dbi:mysql:$db_name:$db_host:$db_port";
	my $self = {
		_connection => DBI->connect($dsn, $db_user, $db_password),
	};
	bless $self, $class;
	return $self;
}

sub close {
	my $self = shift;
	$self->{_connection}->disconnect;
}

sub get_user_info {
	my ($self, $user_id) = @_;
	my $query = 'SELECT * FROM users WHERE id = ?';
	my $op = $self->{_connection}->prepare($query) or die "$op->errstr()";
	$op->execute($user_id) or die "$op->errstr()";
	my %user_info;
	while (my $ref = $op->fetchrow_hashref) {
		%user_info = %$ref;
		break;
	}
	return %user_info;
}

sub get_user_id {
	my ($self, $username, $password) = @_;
	my $query = 'SELECT id FROM users WHERE username = ? and password = ?';
	my $op = $self->{_connection}->prepare($query) or die "$op->errstr()";
	$op->execute($username, $password) or die "$op->errstr()";
	while (my $ref = $op->fetchrow_arrayref) {
		return $$ref[0];
	}
	return -1;
}

sub register_user {
	my ($self, $username, $password) = @_;
	my $query = 'SELECT id FROM users WHERE username = ?';
	my $op = $self->{_connection}->prepare($query) or die "$op->errstr()";
	$op->execute($username) or die "$op->errstr()";
	if ($op->rows == 0) {
		my $query = 'INSERT INTO users(username, password) VALUES(?,?)';
		$self->{_connection}->do($query, undef, $username, $password);
		return 1;
	}
	return 0;
}

sub get_posts {
	my ($self, $page) = @_;
	my $query = 'SELECT posts.id, users.username, posts.title, posts.content FROM posts JOIN users ON users.id = posts.user_id LIMIT ? OFFSET ?';
	my $op = $self->{_connection}->prepare($query) or die "$op->errstr()";
	$op->execute($POSTS_PER_PAGE, $page*$POSTS_PER_PAGE) or die "$op->errstr()";
	my @posts;
	while (my $ref = $op->fetchrow_arrayref) {
		my %d = (
			"id" => $$ref[0],
			"username" => $$ref[1],
			"title" => $$ref[2],
			"content" => $$ref[3],
		);
		push(@posts, \%d);
	}
	return \@posts;
}

sub get_post {
	my ($self, $post_id) = @_;
	my $query = 'SELECT posts.id, users.username, posts.title, posts.content FROM posts JOIN users ON users.id = posts.user_id WHERE posts.id = ?';
	my $op = $self->{_connection}->prepare($query) or die "$op->errstr()";
	$op->execute($post_id) or die "$op->errstr()";
	my %post_data = ();
	while (my $ref = $op->fetchrow_arrayref) {
		%post_data = (
			"id" => $$ref[0],
			"username" => $$ref[1],
			"title" => $$ref[2],
			"content" => $$ref[3],
		);
		break;
	}
	return %post_data;
}

sub get_comments {
	my ($self, $post_id, $page) = @_;
	my $query = 'SELECT comments.id, users.username, comments.content FROM comments JOIN users ON users.id = comments.user_id WHERE comments.post_id = ? ORDER BY comments.id DESC LIMIT ? OFFSET ?';
	my $op = $self->{_connection}->prepare($query) or die "$op->errstr()";
	$op->execute($post_id, $COMMENTS_PER_PAGE, $page*$COMMENTS_PER_PAGE) or die "$op->errstr()";
	my @comments;
	while (my $ref = $op->fetchrow_arrayref) {
		my %d = (
			"id" => $$ref[0],
			"username" => $$ref[1],
			"content" => $$ref[2],
		);
		push(@comments, \%d);
	}
	return \@comments;
}

sub save_comment {
	my ($self, $user_id, $post_id, $content) = @_;
	my $query = 'INSERT INTO comments (user_id, post_id, content) VALUES (?, ?, ?)';
	$self->{_connection}->do($query, undef, $user_id, $post_id, $content);
}

1;
